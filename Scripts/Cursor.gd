extends Node2D
class_name Cursor

# Member Variables
var mousePosition : Vector2
var gridPosition := Vector2.ZERO setget set_gridPosition
#TileMap resource, giving the node access to the underlying DevTile tilemap
var devTileMap : TileMap
#Time before the cursor can move again in seconds
export var ui_cooldown := 0.05

#Script instantiates variable based on value in Timer child node
onready var _timer: Timer = $Timer

# Emitted when clicking on the currently hovered cell or when pressing "ui_accept".
signal select_pressed(coordinates)
# Emitted when the cursor moved to a new cell.
signal moved(new_coordinates)

# Called when the node enters the scene tree for the first time.
func _ready():
	_timer.wait_time = ui_cooldown

# Call after adding node to scene tree
# sets the referance for the correct TileMap and sets the position of the
# curose to the first used cell
func init(inputTileMap : TileMap):
	setTileMap(inputTileMap)
	var usedArray = devTileMap.get_used_cells()
	set_gridPosition(usedArray[0])

# Controls the cursors current position on the grid
# sets the position of the cursor based on coordinates parameter corresponding to the tilemap
func set_gridPosition(gridcoordinates: Vector2) -> void:
	# Skip the work if the coordinates are the same
	if gridcoordinates == gridPosition:
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

# Function that handles mouse and keyboard movement
# uses signals when left click/enter is pressed
func _unhandled_input(event: InputEvent) -> void:
	# If mouse in moved
	if event is InputEventMouseMotion:
		self.set_Position(get_global_mouse_position())
	# if user left clicks or presses enter
	elif event.is_action_pressed("click") or event.is_action_pressed("ui_select"):
		emit_signal("select_pressed", gridPosition)
		get_tree().set_input_as_handled()
	
	# if the user presses an arrow key.
	var should_move := event.is_pressed()
	# If the player is pressing the key in this frame, we allow the cursor to move. If they keep the
	# keypress down, we only want to move after the cooldown timer stops.
	if event.is_echo():
		should_move = should_move and _timer.is_stopped()
	# And if the cursor shouldn't move, we prevent it from doing so.
	if not should_move:
		return
	# Here, we update the cursor's current cell based on the input direction.
	if event.is_action("ui_right"):
		self.gridPosition += Vector2.RIGHT
	elif event.is_action("ui_up"):
		self.gridPosition += Vector2.UP
	elif event.is_action("ui_left"):
		self.gridPosition += Vector2.LEFT
	elif event.is_action("ui_down"):
		self.gridPosition += Vector2.DOWN

# Setter Function for devTileMap
func setTileMap(inputTileMap : TileMap) -> void:
	self.devTileMap = inputTileMap

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
