# Represents and manages the game board. Stores references to entities that are in each cell and
# tells whether cells are occupied or not.
# Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

# Once again, we use our grid resource that we explicitly define in the class.
export var gamegrid: Resource
onready var _pop_up: PopupMenu = get_parent().get_node("PopupMenu")
onready var _turn_queue: TurnQueue = get_parent().get_node("TurnQueue")

# This constant represents the directions in which a unit can move on the board. We will reference
# the constant later in the script.
const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

# We use a dictionary to keep track of the units that are on the board. Each key-value pair in the
# dictionary represents a unit. The key is the position in grid coordinates, while the value is a
# reference to the unit.
# Mapping of coordinates of a cell to a reference to the unit it contains.
var _units := {}

# The board is going to move one unit at a time. When we select a unit, we will save it as our
# `_active_unit` and populate the walkable cells below. This allows us to clear the unit, the
# overlay, and the interactive path drawing later on when the player decides to deselect it.
var _active_unit: Unit
# This is an array of all the cells the `_active_unit` can move to. We will populate the array when
# selecting a unit and use it in the `_move_active_unit()` function below.
var _walkable_cells := []
# This is an array of all the cells the `_active_unit` can move to. We will populate the array when
# selecting a unit and use it in the `_move_active_unit()` function below.
var _attackable_cells := []

onready var _unit_path: UnitPath = $UnitPath
onready var _unit_overlay: UnitOverlay = $UnitOverlay

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Returns `true` if the cell is occupied by a unit.
func is_occupied(cell: Vector2) -> bool:
	return true if _units.has(cell) else false

# Clears, and refills the `_units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
	_units.clear()
	# In this demo, we loop over the node's children and filter them to find the units. As your game
	# becomes more complex, you may want to use the node group feature instead to place your units
	# anywhere in the scene tree.
	for child in get_children():
		# We can use the "as" keyword to cast the child to a given type. If the child is not of type
		# Unit, the variable will be null.
		var unit := child as Unit
		if not unit:
			continue
		# As mentioned when introducing the units variable, we use the grid coordinates for the key
		# and a reference to the unit for the value. This allows us to access a unit given its grid
		# coordinates.
		_units[unit.cell] = unit

# Selects the unit in the `cell` if there's one there.
# Sets it as the `_active_unit` and draws its walkable cells and interactive move path.
# The board reacts to the signals emitted by the cursor. And it does so by calling functions that
# select and move a unit.
func _select_unit(cell: Vector2) -> void:
	# Here's some optional defensive code: we return early from the function if the unit's not
	# registered in the `cell`.
	if not _units.has(cell):
		_pop_up.popup_menu($Cursor.position,false,false,true)
		return
	_active_unit = _units[cell]
	if not _active_unit.is_turnReady():
		_clear_active_unit()
		_pop_up.popup_menu($Cursor.position,false,false,true)
		return
	_active_unit.is_selected = true
	print(_active_unit)
	print("Is at: " + String(_active_unit.cell))
	_walkable_cells = gamegrid.get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells, _active_unit)

# Selects the unit in the `cell` if there's one there.
# Draws its attackable cells.
# The board reacts to the signals emitted by the cursor. And it does so by calling functions that
# select and move a unit.
func _show_range(cell: Vector2) -> void:
	# Here's some optional defensive code: we return early from the function if the unit's not
	# registered in the `cell`.
	if not _units.has(cell):
		return
	_attackable_cells = gamegrid.get_attackable_cells(_units[cell])
	_unit_overlay.draw_red(_attackable_cells)

# Deselects the active unit, clearing the cells overlay and interactive path drawing.
# We need it for the `_move_active_unit()` function below, and we'll use it again in a moment.
func _deselect_active_unit() -> void:
	_active_unit.is_selected = false
	_unit_overlay.totalclear()
	_unit_path.stop()

# Clears the reference to the _active_unit and the corresponding walkable cells.
# We need it for the `_move_active_unit()` function below.
func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()

# Updates the _units dictionary with the target position for the unit and asks the _active_unit to
# walk to it.
func _move_active_unit(new_cell: Vector2) -> void:
	# Security chek that the selected cell is invalid
	if _active_unit.cell != new_cell:
		if is_occupied(new_cell) or not new_cell in _walkable_cells:
			return
	# We also deselect it, clearing up the overlay and path.
	_deselect_active_unit()
	# Disable the Cursor to stop moving
	$Cursor.active = false

	# Check to see if the unit gets trapped by enemy unit
	var trapped := false
	var trapped_cell := 0
	for cell in _unit_path.current_path:
		if (gamegrid.is_occupied(cell)
		&& gamegrid.get_unit(cell).get_unit_team() != _active_unit.get_unit_team()):
			trapped = true
			break
		trapped_cell += 1
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
		_active_unit.flip_turnReady()
	if not trapped:
		#TODO: More unit move functionality HERE
		_pop_up.popup_menu($Cursor.position,gamegrid.enemy_in_range(_active_unit, gamegrid.get_unit_position(_active_unit), new_cell),true,false)
		# Wait until the player makes a selection
		yield(_pop_up, "selection")
		# When moving a unit, we need to update our `_units` dictionary. We instantly save it in the
		# target cell even if the unit itself will take time to walk there.
		# While it's walking, the player won't be able to issue new commands.
	if _active_unit:
		var previous_data = gamegrid.find_unit(_active_unit)
		previous_data.clear_unit()
		_units.erase(previous_data.getCoordinates())
		gamegrid.get_GridData_by_position(new_cell).setUnit(_active_unit)
		_units[new_cell] = _active_unit
		print(_active_unit)
		print(" moving to: " + String(new_cell))
		_active_unit.set_cell(new_cell)
		_clear_active_unit()
		_unit_path.clear_path()
	$Cursor.active = true

# Selects or moves a unit based on where the cursor is.
func _on_Cursor_select_pressed(cell: Vector2) -> void:
	# The cursor's "select_pressed" means that the player wants to interact with a cell. Depending
	# on the board's current state, this interaction means either that we want to select a unit or
	# that we want to give it a move order.
	if not _active_unit:
		_select_unit(cell)
	elif _active_unit.is_selected && _active_unit.playerOwner == _turn_queue.activePlayer:
		_move_active_unit(cell)



# Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	# When the cursor moves, and we already have an active unit selected, we want to update the
	# interactive path drawing.
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit, new_cell)

# Deselects or shows the range of a unit
func _on_Cursor_cancel_pressed(cell: Vector2) -> void:
	if _active_unit:
		_deselect_active_unit()
		_clear_active_unit()
		_unit_path.clear_path()
	else:
		_pop_up.close()
		_show_range(cell)

# Stops displaying the range on release
func _on_Cursor_cancel_released(cell: Vector2) -> void:
	if _active_unit:
		return
	_unit_overlay.totalclear()

func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()
		_clear_active_unit()
		_unit_path.clear_path()
		get_tree().set_input_as_handled()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_PopupMenu_selection(selection : String):
	match selection:
		"Wait":
			print(selection)
			_pop_up.close()
			_active_unit.flip_turnReady()
		"Attack":
			print(selection)
			_pop_up.close()
			pass
		"End Turn":
			var temp_units = gamegrid.get_players_units(_turn_queue.activePlayer)
			if not temp_units.empty():
				for unit in temp_units:
					if not unit.is_turnReady():
						unit.flip_turnReady()
			_pop_up.close()
			_turn_queue.nextTurn()
			for data in gamegrid.array:
				if data != null:
					if data.getUnit() != null:
						print (data.getUnit().cell)
		"Cancel":
			print(selection)
			_pop_up.close()
			if _active_unit:
				_deselect_active_unit()
				_active_unit.cell = gamegrid.get_unit_position(_active_unit)
				_active_unit.update_position()
				_clear_active_unit()
				_unit_path.clear_path()


func _on_PopupMenu_popup_hide():
	pass # Replace with function body.