extends Node2D

export(String) var playerName
export(int) var team = 1
export var commander = "res://Objects/Commander.tscn"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getCommander() -> Node2D:
	return commander

func getName() -> String:
	return playerName

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
