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
		if gamegrid.get_unit(cell).is_turnReady():
			_select_unit(cell)
		else:
			_cursor.deactivate(true)
			_pop_up.popup_menu(_cursor.position,false,false,true)
	elif _active_unit:
		if _active_unit.playerOwner == _turn_queue.activePlayer:
			_move_active_unit(cell)
	else:
		_cursor.deactivate(true)
		_pop_up.popup_menu(_cursor.position,false,false,true)

# Selects the unit in the `cell` if there's one there.
# Sets it as the `_active_unit` and draws its walkable cells and interactive move path.
func _select_unit(cell: Vector2) -> void:
	# Here's some optional defensive code: we return early from the function if the unit's not
	# registered in the `cell`.
	if not is_occupied(cell):
		return
	_active_unit = gamegrid.get_unit(cell)
	_active_unit.is_selected = true
	_walkable_cells = gamegrid.get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells, _active_unit)

# Visually moves the active unit to the location
# then presents the correct context menu
func _move_active_unit(new_position: Vector2) -> void:
	_active_unit.is_selected = false
	# Security chek that the selected cell is invalid
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
	yield(_active_unit, "walk_finished")
	if trapped:
		#TODO: Play trapped effect
		set_new_position(_active_unit, new_position)
		_active_unit.flip_turnReady()
		_clear_active_unit()
		_cursor.activate()
	else:
		_stored_new_position = new_position
		_pop_up.popup_menu(_cursor.position,\
			gamegrid.enemy_in_range(_active_unit, gamegrid.get_unit_position(_active_unit),new_position),\
			true,false)

# Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	# When the cursor moves, and we already have an active unit selected, we want to update the
	# interactive path drawing.
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit, new_cell)

# Deselects or shows the range of a unit
func _on_Cursor_cancel_pressed(cell: Vector2) -> void:
	# if the unit is only selected
	if _active_unit:
		_active_unit.is_selected = false
		_clear_active_unit()
	else:
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
		if selection is String:
			if selection == "Cancel":
				_combat_cursor.deactivate()
				_pop_up.popup_menu(_cursor.position,\
					gamegrid.enemy_in_range(_active_unit, gamegrid.get_unit_position(_active_unit),_stored_new_position),\
					true,false)
				_unit_overlay.totalclear()
				_attacking = false
				# Show the cursor but do not reactivate
				_cursor.visible = true
		elif selection is Unit:
			_combat_cursor.deactivate()
			_unit_overlay.totalclear()
			set_new_position(_active_unit, _stored_new_position)
			gamegrid.unit_combat(_active_unit, selection)
			_attacking = false
			_active_unit.flip_turnReady()
			_clear_active_unit()
			_cursor.activate()


func _on_CombatCursor_moved(new_coordinates):
	if not _active_unit:
		# should not get in here
		pass
	else:
		var min_damage = gamegrid.calculate_min_damage(_active_unit, gamegrid.get_unit(new_coordinates))
		var max_damage = gamegrid.calculate_max_damage(_active_unit, gamegrid.get_unit(new_coordinates))
		print("Damage Done: " + String(min_damage) + "%-" + String(max_damage) + "%")
		var target = gamegrid.get_unit(new_coordinates)
		if _active_unit.attack_type == Constants.ATTACK_TYPE.DIRECT && \
		target.attack_type == Constants.ATTACK_TYPE.DIRECT:
			if not min_damage > target.health:
				var min_damage_taken = gamegrid.calculate_min_damage(target, _active_unit, max_damage)
				var max_damage_taken = gamegrid.calculate_max_damage(target, _active_unit, min_damage)
				if min_damage_taken < 0:
					min_damage_taken = 0
				print("Damage Received: " + String(min_damage_taken) + "%-" + String(max_damage_taken) + "%")
			else:
				print("Damage Received: 0%")
