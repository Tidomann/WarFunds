extends Node2D
class_name CombatCursor

# Member Variables
var mousePosition : Vector2
var gridPosition := Vector2.ZERO setget set_gridPosition
#TileMap resource, giving the node access to the underlying DevTile tilemap
var devTileMap : TileMap
#Time before the cursor can move again in seconds
export var ui_cooldown := 0.05

#Script instantiates variable based on value in Timer child node
onready var _timer: Timer = $Timer

var _targets : Array
var _targets_positions : Array
var _target_index : int
var _targeted_unit : Unit

# Emitted when clicking on the currently hovered cell or when pressing "ui_accept".
signal combat_selection
# Emitted when the cursor moved to a new cell.
signal moved(new_coordinates)
# Emitted when clicking on the currently hovered cell or when pressing "ui_cancel".
signal cancel_pressed(coordinates)
# Emitted when clicking on the currently hovered cell or when pressing "ui_cancel".
signal cancel_released(coordinates)

var active:= false
# Called when the node enters the scene tree for the first time.
func _ready():

	_timer.wait_time = ui_cooldown

# Call after adding node to scene tree
# sets the referance for the correct TileMap and sets the position of the
# curose to the first used cell
func init(inputTileMap : TileMap):
	setTileMap(inputTileMap)
	active = false

# Controls the cursors current position on the grid
# sets the position of the cursor based on coordinates parameter corresponding to the tilemap
func set_gridPosition(gridcoordinates: Vector2) -> void:
	# Skip the work if the coordinates are the same
	if gridcoordinates == gridPosition:
		emit_signal("moved", gridPosition)
		return
	# Do not move if the tilemap is null
	if devTileMap.get_cellv(gridcoordinates) == -1:
		return
	gridPosition = gridcoordinates
	mousePosition = devTileMap.map_to_world(gridcoordinates)
	mousePosition.x += devTileMap.cell_size.x/2
	mousePosition.y += devTileMap.cell_size.y/2
	self.position = mousePosition
	emit_signal("moved", gridPosition)
	_timer.start()

# Failsafe if we are dumb
func update_position() -> void:
	pass
	
# Sets the position of the cursor based on the global position parameter
func set_Position(globalposition: Vector2) -> void:
	set_gridPosition(devTileMap.world_to_map(globalposition))

func get_Position_on_grid() -> Vector2:
	return devTileMap.world_to_map(position)

# Function that handles mouse and keyboard movement
# uses signals when left click/enter is pressed
func _unhandled_input(event: InputEvent) -> void:
	# If mouse in moved
	if active && not _targets.empty():
		if event is InputEventMouseMotion:
			for unit in _targets:
				if devTileMap.world_to_map(get_global_mouse_position()) == unit.cell:
					_targeted_unit = unit
					_target_index = _targets.find(unit)
					self.set_gridPosition(unit.cell)
		# if user left clicks or presses enter
		elif event.is_action_pressed("ui_select"):
			emit_signal("combat_selection", _targeted_unit)
			get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			_targeted_unit = null
			_targets.clear()
			emit_signal("combat_selection", "Cancel")
			get_tree().set_input_as_handled()
		#elif event.is_action_released("ui_cancel"):
		#	emit_signal("cancel_released")
		#	get_tree().set_input_as_handled()
	
		# if the user presses an arrow key.
		var should_move := event.is_pressed()
		# If the player is pressing the key in this frame, we allow the cursor to move. If they keep the
		# keypress down, we only want to move after the cooldown timer stops.
		if event.is_echo():
			should_move = should_move and _timer.is_stopped()
		if event is InputEventJoypadMotion:
			var strength = event.axis_value
			should_move = abs(strength) == 1 and _timer.is_stopped()
		# And if the cursor shouldn't move, we prevent it from doing so.
		if not should_move:
			return
		# Here, we update the cursor's current cell based on the input direction.
		if event.is_action_pressed("ui_right")or \
		(event.is_action("ui_right") && event is InputEventKey):
			_target_index = (_target_index + 1) % _targets.size()
			_targeted_unit = _targets[_target_index]
			self.gridPosition = _targeted_unit.cell
		elif event.is_action_pressed("ui_up") or \
		(event.is_action("ui_up") && event is InputEventKey):
			_target_index = (_target_index + 1) % _targets.size()
			_targeted_unit = _targets[_target_index]
			self.gridPosition = _targeted_unit.cell
		elif event.is_action_pressed("ui_left") or \
		(event.is_action("ui_left") && event is InputEventKey):
			_target_index = (_target_index - 1) % _targets.size()
			_targeted_unit = _targets[_target_index]
			self.gridPosition = _targeted_unit.cell
		elif event.is_action_pressed("ui_down") or \
		(event.is_action("ui_down") && event is InputEventKey):
			_target_index = (_target_index - 1) % _targets.size()
			_targeted_unit = _targets[_target_index]
			self.gridPosition = _targeted_unit.cell

# Setter Function for devTileMap
func setTileMap(inputTileMap : TileMap) -> void:
	self.devTileMap = inputTileMap

func activate(target_array : Array) -> void:
	_targets = target_array
	_targets_positions.clear()
	for unit in _targets:
		_targets_positions.append(unit.cell)
	set_gridPosition(_targets[0].cell)
	_targeted_unit = _targets[0]
	self.visible = true
	active = true

func deactivate() -> void:
	_targets.clear()
	_targets_positions.clear()
	_targeted_unit = null
	_target_index = 0
	self.visible = false
	active = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
