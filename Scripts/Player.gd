extends Node2D

# Member Variables
export(String) var playerName
export(int) var team = 1
export var commander_path := @""
export(int) var funds
onready var commander : Node2D = self.get_node(commander_path)
#onready var _sprite: Sprite = $PathFollow2D/Sprite
export(String, "Right", "Left") var facing
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	commander = get_node(commander_path)

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