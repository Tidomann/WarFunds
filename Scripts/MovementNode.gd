extends Object

class_name MovementNode

# Declare member variables here. Examples:
var cell:Vector2
var movement:int

func _init()->void:
	cell = Vector2.ZERO
	movement = 0

func setNode(inCell:Vector2, inMove:int):
	cell = inCell
	movement = inMove

func get_cell() -> Vector2:
	return cell

func get_movement() -> int:
	return movement

func has(value : Vector2) -> bool:
	return (cell == value)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
