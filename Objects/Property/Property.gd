## Represents a property on the game board.
tool
class_name Property
extends Node2D

export var player_path := @""
onready var playerOwner : Node2D = self.get_node(player_path)

export(bool) var turnReady = true

## Shared resource of type Grid, used to calculate map coordinates.
export var grid: Resource
## Coordinates of the property
export var cell : Vector2
## Referance to the property constant
export(Constants.PROPERTY) var property_referance
## The Properties Health
export var health := 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_position() -> void:
	position = grid.calculate_map_position(cell)

func set_turnReady(ready : bool) -> void:
	turnReady = ready

func get_team() -> int:
	return playerOwner.team



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
