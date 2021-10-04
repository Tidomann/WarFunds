class_name UnitPath
extends TileMap

export var grid: Resource

# This variable holds a reference to a PathFinder object. We'll create a new one every time the 
# player select a unit.
var pathfinder: PathFinder


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
