## Represents a unit on the game board.
## The board manages its position inside the game grid.
## The unit itself holds stats and a visual representation that moves smoothly in the game world.
tool
class_name Unit
extends Path2D

## Emitted when the unit reached the end of a path along which it was walking.
signal walk_finished

export var playerOwner = "res://Objects/BattleMap Objects/Player.tscn"
## Shared resource of type Grid, used to calculate map coordinates.
export var grid: Resource
## Coordinates of the current cell the unit moved to.
export var cell : Vector2
## Texture representing the unit.
export var skin: Texture setget set_skin
## Distance to which the unit can walk in cells.
export var move_range := 6
## Type of movement for the unit
export(Constants.MOVEMENT_TYPE) var movement_type
## The unit's combat attack range.
export var atk_range := 1
## The unit's combat attack minimum range.
export var min_atk_range := 0
## Offset to apply to the `skin` sprite in pixels.
export var skin_offset := Vector2.ZERO setget set_skin_offset
## The unit's move speed when it's moving along a path.
export var move_speed := 600.0

export(bool) var turnReady = true

## Toggles the "selected" animation on the unit.
var is_selected := false setget set_is_selected

var _is_walking := false setget _set_is_walking

onready var _sprite: Sprite = $PathFollow2D/Sprite
onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _path_follow: PathFollow2D = $PathFollow2D


func _ready() -> void:
	set_process(false)
	# We create the curve resource here because creating it in the editor prevents us from
	# moving the unit.
	if not Engine.editor_hint:
		curve = Curve2D.new()

func update_position() -> void:
	#self.cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)
	
func _process(delta: float) -> void:
	_path_follow.offset += move_speed * delta

	if _path_follow.offset >= curve.get_baked_length():
		self._is_walking = false
		_path_follow.offset = 0
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		emit_signal("walk_finished")


## Starts walking along the `path`.
## `path` is an array of grid coordinates that the function converts to map coordinates.
func walk_along(path: PoolVector2Array) -> void:
	if path.empty():
		return

	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	self._is_walking = true


func set_cell(value: Vector2) -> void:
	cell = grid.clamp(value)

func get_cell() -> Vector2:
	return cell


func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		_anim_player.play("selected")
	else:
		_anim_player.play("idle")


func set_skin(value: Texture) -> void:
	skin = value
	if not _sprite:
		yield(self, "ready")
	_sprite.texture = value


func set_skin_offset(value: Vector2) -> void:
	skin_offset = value
	if not _sprite:
		yield(self, "ready")
	_sprite.position = value


func _set_is_walking(value: bool) -> void:
	_is_walking = value
	set_process(_is_walking)

func getPlayerOwner() -> Node2D:
	return playerOwner

func is_turnReady() -> bool:
	return turnReady

func flip_turnReady() -> void:
	turnReady = !turnReady
