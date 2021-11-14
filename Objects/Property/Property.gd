## Represents a property on the game board.
tool
class_name Property
extends Node2D

onready var playerOwner : Node2D

export(bool) var turnReady = true
## Coordinates of the property
export var cell : Vector2
## Referance to the property constant
export(Constants.PROPERTY) var property_referance
## The Properties Health
export var health := 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_turnReady(ready : bool) -> void:
	turnReady = ready

func get_team() -> int:
	return playerOwner.team



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
