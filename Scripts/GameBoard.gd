# Represents and manages the game board. Stores references to entities that are in each cell and
# tells whether cells are occupied or not.
# Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

# Once again, we use our grid resource that we explicitly define in the class.
export var gamegrid: Resource
onready var _pop_up: PopupMenu = get_parent().get_node("PopupMenu")
onready var _turn_queue: TurnQueue = get_parent().get_node("TurnQueue")
onready var _cursor: Cursor = $Cursor
onready var _combat_cursor: CombatCursor = $CombatCursor
onready var _unit_path: UnitPath = $UnitPath
onready var _unit_overlay: UnitOverlay = $UnitOverlay
onready var _property_tiles: TileMap = get_parent().get_node("PropertyTiles")
onready var _human_player = _turn_queue.get_node("Human")
onready var _buy_menu = get_parent().get_node("BuyMenu")

# Represents the directions which can neighbour a cell
const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]


# The unit currently selected
var _active_unit: Unit
# Storing the array of cells a unit can move to
var _walkable_cells := []
# Storing the array of cell a unit can attack
var _attackable_cells := []
# Storing the new position of a unit
var _stored_new_position : Vector2

var signaled_player
var signaled_income
signal income_changed(signaled_player, signaled_income)

var _attacking : bool

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Returns `true` if the cell is occupied by a unit.
func is_occupied(cell: Vector2) -> bool:
	return gamegrid.is_occupied(cell)

# Selects the unit in the `cell` if there's one there.
# and draws its attackable cells.
func _show_range(cell: Vector2) -> void:
	# Here's some optional defensive code: we return early from the function if the unit's not
	# registered in the `cell`.
	if not is_occupied(cell):
		return
	var unit = gamegrid.get_unit(cell)
	_attackable_cells = gamegrid.get_attackable_cells(unit)
	# If the unit is attack type other- show minimum range
	if unit.attack_type == Constants.ATTACK_TYPE.OTHER:
		if unit.playerOwner == _turn_queue.activePlayer:
			for coordinate in gamegrid._flood_fill(cell, unit.min_atk_range,
			Constants.MOVEMENT_TYPE.AIR, true):
				if _attackable_cells.has(coordinate):
					_attackable_cells.erase(coordinate)
	_unit_overlay.draw_red(_attackable_cells)

# Deselects the active unit, clear overlay and path drawing.
func _clear_path_overlay() -> void:
	_unit_overlay.totalclear()
	_unit_path.stop()

# Clears the _active_unit and each cell array.
func _clear_active_unit() -> void:
	_clear_path_overlay()
	_unit_path.clear_path()
	_active_unit = null
	_walkable_cells.clear()
	_attackable_cells.clear()

func set_new_position(unit : Unit, new_cell : Vector2) -> void:
	var previous_data = gamegrid.find_unit(unit)
	previous_data.clear_unit()
	gamegrid.get_GridData_by_position(new_cell).setUnit(unit)
	_active_unit.set_cell(new_cell)

# Selects or moves a unit based on where the cursor is.
func _on_Cursor_select_pressed(cell: Vector2) -> void:
	# Dependingon the board's current state,
	# select a unit or that we want to give it a move order.
	if not _active_unit && is_occupied(cell):
		$SoundManager.playsound("Select")
		if gamegrid.get_unit(cell).is_turnReady():
			_select_unit(cell)
		else:
			_cursor.deactivate(true)
			_pop_up.popup_menu(_cursor.position,false,false,false,false,0,false, true, _turn_queue.activePlayer.commander.canUsePower(), true)
	elif _active_unit:
		if _active_unit.playerOwner == _turn_queue.activePlayer:
			if not gamegrid.is_occupied(cell) || gamegrid.get_unit(cell) == _active_unit:
				$SoundManager.playsound("Select")
				if _active_unit.cell == cell:
					_unit_path.draw(_active_unit, cell)
				_move_active_unit(cell)
			else:
				$SoundManager.playsound("Error")
		else:
			$SoundManager.playsound("Error")
	else:
		if gamegrid.has_property(cell):
			if gamegrid.get_property(cell).property_referance == Constants.PROPERTY.BASE && gamegrid.get_property(cell).playerOwner == _turn_queue.activePlayer:
				_buy_menu.popup_menu(_cursor.position, cell, _turn_queue.activePlayer)
			else:
				$SoundManager.playsound("Select")
				_cursor.deactivate(true)
				_pop_up.popup_menu(_cursor.position,false,false,false,false,0,false, true, _turn_queue.activePlayer.commander.canUsePower(), true)
		else:
			$SoundManager.playsound("Select")
			_cursor.deactivate(true)
			_pop_up.popup_menu(_cursor.position,false,false,false,false,0,false, true, _turn_queue.activePlayer.commander.canUsePower(), true)

# Selects the unit in the `cell` if there's one there.
# Sets it as the `_active_unit` and draws its walkable cells and interactive move path.
func _select_unit(cell: Vector2) -> void:
	# Here's some optional defensive code: we return early from the function if the unit's not
	# registered in the `cell`.
	if not is_occupied(cell):
		return
	$SoundManager.playsound("Select")
	_active_unit = gamegrid.get_unit(cell)
	_active_unit.is_selected = true
	_walkable_cells = gamegrid.get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells, _active_unit)

# Visually moves the active unit to the location
# then presents the correct context menu
func _move_active_unit(new_position: Vector2) -> void:
	# Security check if the selected cell is invalid
	if _active_unit.cell != new_position:
		if is_occupied(new_position) or not new_position in _walkable_cells:
			return
	# Clear up the UnitOverlay and UnitPath
	_clear_path_overlay()
	# Disable the Cursor to stop moving
	_cursor.deactivate(false)
	# Check to see if the unit gets trapped by enemy unit
	var trapped := false
	var trapped_cell := 0
	# Iterate through the currently stored path
	for cell in _unit_path.current_path:
		# If the cell in the path is occupied by an enemy calculate the indexed cell
		if gamegrid.is_occupied(cell):
			if gamegrid.get_unit(cell).get_unit_team() != _active_unit.get_unit_team():
				trapped = true
				break
		trapped_cell += 1
	# If the unit is trapped update the path up until trapped
	if trapped:
		var new_array := []
		for cell in range(0, trapped_cell):
			new_array.append(_unit_path.current_path[cell])
		_unit_path.current_path = PoolVector2Array(new_array)
	# We then ask the unit to walk along the path stored in the UnitPath instance and wait until it
	# finished.
	_active_unit.walk_along(_unit_path.current_path)
	if _unit_path.current_path.size() > 1:
		match _active_unit.movement_type:
			Constants.MOVEMENT_TYPE.INFANTRY:
				$SoundManager.playsound("InfantryMove")
			Constants.MOVEMENT_TYPE.MECH:
				$SoundManager.playsound("InfantryMove")
			Constants.MOVEMENT_TYPE.TREAD:
				$SoundManager.playsound("TreadMove")
			Constants.MOVEMENT_TYPE.TIRES:
				$SoundManager.playsound("TireMove")
		yield(_active_unit, "walk_finished")
	
	if trapped:
		#TODO: Play trapped effect
		_active_unit.is_selected = false
		set_new_position(_active_unit, new_position)
		_active_unit.flip_turnReady()
		_clear_active_unit()
		_cursor.activate()
	else:
		_stored_new_position = new_position
		# Could try and move this to the end of all commands- but may affect turn end modulations
		_active_unit.is_selected = false
		_pop_up.popup_menu(_cursor.position,\
			gamegrid.enemy_in_range(_active_unit, gamegrid.get_unit_position(_active_unit),new_position),\
			gamegrid.can_capture(new_position, _active_unit),\
			can_buy_heal(_active_unit,gamegrid.get_unit_position(_active_unit)),\
			can_afford_heal(_active_unit),\
			heal_cost(_active_unit),\
			 true,false, false, false)
	#TODO: Instead of matching active unit, just call all movement audio to stop playing?
	match _active_unit.movement_type:
		Constants.MOVEMENT_TYPE.INFANTRY:
			$SoundManager.stopsound("InfantryMove")
		Constants.MOVEMENT_TYPE.MECH:
			$SoundManager.stopsound("InfantryMove")
		Constants.MOVEMENT_TYPE.TREAD:
				$SoundManager.stopsound("TreadMove")
		Constants.MOVEMENT_TYPE.TIRES:
				$SoundManager.stopsound("TireMove")

# Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	# When the cursor moves, and we already have an active unit selected, we want to update the
	# interactive path drawing.
	$Cursor/SoundMoveCursor.play()
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit, new_cell)

# Deselects or shows the range of a unit
func _on_Cursor_cancel_pressed(cell: Vector2) -> void:
	# if the unit is only selected
	if _active_unit:
		$SoundManager.playsound("Cancel")
		_active_unit.is_selected = false
		_clear_active_unit()
	else:
		$SoundManager.playsound("Cancel")
		_pop_up.close()
		_show_range(cell)

# Stops displaying the range on release
func _on_Cursor_cancel_released(_cell: Vector2) -> void:
	if _active_unit:
		return
	_unit_overlay.totalclear()

func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel") and not _active_unit._is_walking:
		_clear_path_overlay()
		_clear_active_unit()
		get_tree().set_input_as_handled()

func _on_PopupMenu_selection(selection : String):
	match selection:
		"Wait":
			print(selection)
			set_new_position(_active_unit, _stored_new_position)
			_active_unit.flip_turnReady()
			if is_game_finished(_human_player):
				end_game(_human_player)
			else:
				_clear_active_unit()
				_pop_up.close()
				_cursor.activate()
		"Attack":
			print(selection)
			_cursor.deactivate(true)
			_attacking = true
			var targets = gamegrid.get_targets(_active_unit, $Cursor.get_Position_on_grid())
			var target_positions = []
			if targets.size() > 1:
				for defender in targets:
					target_positions.append(defender.cell)
			else:
				target_positions.append(targets[0].cell)
			_unit_overlay.draw_red(target_positions)
			_combat_cursor.activate(targets)
		"End Turn":
			print(selection)
			_clear_active_unit()
			var temp_units = gamegrid.get_players_units(_turn_queue.activePlayer)
			if not temp_units.empty():
				for unit in temp_units:
					if not unit.is_turnReady():
						unit.flip_turnReady()
			_turn_queue.nextTurn()
			print(_turn_queue.activePlayer.playerName + "'s turn.")
			_pop_up.close()
			_cursor.activate()
		"Power":
			print(selection)
			_clear_active_unit()
			_turn_queue.activePlayer.commander.use_power()
			#TODO: YIELD to commander power?
			if is_game_finished(_human_player):
				end_game(_human_player)
			else:
				_pop_up.close()
		"Capture":
			print(selection)
			set_new_position(_active_unit, _stored_new_position)
			_active_unit.flip_turnReady()
			var game_data = gamegrid.array[gamegrid.as_index(_stored_new_position)]
			var previous_owner = game_data.property.playerOwner
			if game_data.property.capture(_active_unit):
				if _active_unit.get_unit_team() == _human_player.team:
					#Ally = good capture
					$SoundManager.playsound("CaptureCompleteGood")
				else:
					#AI = bad capture
					$SoundManager.playsound("CaptureCompleteBad")
				get_parent().set_property(_stored_new_position, _active_unit.playerOwner)
				signaled_player = previous_owner
				signaled_income = gamegrid.calculate_income(signaled_player)
				emit_signal("income_changed", signaled_player, signaled_income)
				signaled_player = game_data.property.playerOwner
				signaled_income = gamegrid.calculate_income(signaled_player)
				emit_signal("income_changed", signaled_player, signaled_income)
			else:
				#One capture turn = Incomplete Capture
				$SoundManager.playsound("CaptureIncomplete")
			_clear_active_unit()
			_pop_up.close()
			if is_game_finished(_human_player):
				end_game(_human_player)
			else:
				_cursor.activate()
		"Heal":
			print(selection)
			set_new_position(_active_unit, _stored_new_position)
			_active_unit.flip_turnReady()
			if is_game_finished(_human_player):
				end_game(_human_player)
			else:
				# This assumes a unit will never exceed 100 health
				$SoundManager.playsound("Heal")
				# ADJUST HEALING COST BALANCE HERE
				_active_unit.playerOwner.addFunds(-_active_unit.get_healing(100) * 2*_active_unit.playerOwner.commander.get_heal_discount())
				_clear_active_unit()
				_pop_up.close()
				_cursor.activate()
			


func _on_PopupMenu_popup_hide():
	if _active_unit && not _attacking:
		# Reset the position of the active unit
		_active_unit.cell = gamegrid.get_unit_position(_active_unit)
		_active_unit.update_position()
		_clear_active_unit()
	_pop_up.close()
	if not _attacking:
		_cursor.activate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CombatCursor_combat_selection(selection):
	if not _active_unit:
		# should not get in here
		pass
	else:
		$CanvasLayer/FCTManager.visible = false
		if selection is String:
			if selection == "Cancel":
				$SoundManager.playsound("Cancel")
				_combat_cursor.deactivate()
				_pop_up.popup_menu(_cursor.position,\
				gamegrid.enemy_in_range(_active_unit, gamegrid.get_unit_position(_active_unit),_stored_new_position),\
				gamegrid.can_capture(_stored_new_position, _active_unit),\
				can_buy_heal(_active_unit,gamegrid.get_unit_position(_active_unit)),\
				can_afford_heal(_active_unit),\
				heal_cost(_active_unit),\
				true,false, false, false)
				_unit_overlay.totalclear()
				_attacking = false
				# Show the cursor but do not reactivate
				_cursor.visible = true
		elif selection is Unit:
			$SoundManager.playsound("Attack")
			_combat_cursor.deactivate()
			_unit_overlay.totalclear()
			set_new_position(_active_unit, _stored_new_position)
			var now_max_power = not _active_unit.playerOwner.commander.canUsePower()
			gamegrid.unit_combat(_active_unit, selection)
			if now_max_power && _active_unit.playerOwner.commander.canUsePower():
				$SoundManager.playsound("PowerReady")
			_attacking = false
			
			if _active_unit.is_turnReady():
				_active_unit.flip_turnReady()
			if is_game_finished(_human_player):
				end_game(_human_player)
			else:
				_clear_active_unit()
				_cursor.activate()


func _on_CombatCursor_moved(new_coordinates):
	if not _active_unit:
		# should not get in here
		pass
	else:
		$SoundManager.playsound("MoveAttackCursor")
		var min_damage = gamegrid.calculate_min_damage(_active_unit, gamegrid.get_unit(new_coordinates))
		var max_damage = gamegrid.calculate_max_damage(_active_unit, gamegrid.get_unit(new_coordinates))
		
		var dmgdone
		var dmgtaken
		var combatcursor = get_node("CombatCursor").position
		
		print("Damage Done: " + String(min_damage) + "%-" + String(max_damage) + "%")
		dmgdone       = " ->  " + String(min_damage) + " %- " + String(max_damage) + " %"
		var target = gamegrid.get_unit(new_coordinates)
		$CanvasLayer/FCTManager.rect_position.x = combatcursor.x + 16
		$CanvasLayer/FCTManager.rect_position.y = combatcursor.y
		if _active_unit.attack_type == Constants.ATTACK_TYPE.DIRECT && \
		target.attack_type == Constants.ATTACK_TYPE.DIRECT:
			if not min_damage > target.health:
				var min_damage_taken = gamegrid.calculate_min_damage(target, _active_unit, max_damage)
				var max_damage_taken = gamegrid.calculate_max_damage(target, _active_unit, min_damage)
				if min_damage_taken < 0:
					min_damage_taken = 0
				print("Damage Received: " + String(min_damage_taken) + "%-" + String(max_damage_taken) + "%")
				dmgtaken = " <-  " + String(min_damage_taken) + " %- " + String(max_damage_taken) + " %"
			else:
				print("Damage Received: 0%")
				dmgtaken = " <-  0 %"
			$CanvasLayer/FCTManager.show_value(_active_unit, dmgdone, target, dmgtaken)
		else:
			$CanvasLayer/FCTManager.show_value(_active_unit, dmgdone, target, "0")

func can_buy_heal(unit : Unit, old_position : Vector2) -> bool:
	if unit.cell == old_position && unit.health < 100:
		if gamegrid.has_property(unit.cell):
			if gamegrid.get_property(unit.cell).playerOwner == unit.playerOwner:
				return true
	return false

func can_afford_heal(unit : Unit) -> bool:
	var amount_healed = unit.heal_differance(100)
	# ADJUST HEALING COST BALANCE HERE
	var cost = amount_healed*0.1*unit.get_cost()*2*unit.playerOwner.commander.get_heal_discount()
	return unit.playerOwner.funds > cost

func heal_cost(unit : Unit) -> int:
	# ADJUST HEALING COST BALANCE HERE
	return int(unit.heal_differance(100)*0.1*unit.get_cost()*2*unit.playerOwner.commander.get_heal_discount())

func is_game_finished(human : Node2D) -> bool:
	return get_parent().game_finished(human)
	
	
func end_game(human : Node2D) -> void:
	if get_parent().is_victory(human):
		get_parent().victory()
	else:
		get_parent().defeat()
