extends Node2D

# Member Variables
export(String) var playerName
export(int) var team = 1
export var commander = "res://Objects/Commander.tscn"

export(int) var funds

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getCommander() -> Node2D:
	return commander

#Returns the name of the player
func getName() -> String:
	return playerName

#access commander addpower function through player
func addPower(amount : float) -> void:
	commander.addPower(amount)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
