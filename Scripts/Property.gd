## Represents a property on the game board.
tool
class_name PropertyWF
extends Reference
var playerOwner : Node2D

var turnReady := true
## Coordinates of the property
var cell : Vector2
## Referance to the property constant
var property_referance
## The Properties Health
var health := 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_turnReady(ready : bool) -> void:
	turnReady = ready

func get_team() -> int:
	return playerOwner.team

func capture(unit : Unit) -> bool:
	var damage = int(unit.health*0.1)
	health -= damage
	if health <= 0:
		playerOwner = unit.playerOwner
		health = 20
		return true
	return false



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
