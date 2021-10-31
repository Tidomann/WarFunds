extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var playerdata = load("res://Objects/Interface/UIPlayerData.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func add_player(player : Node2D):
	var uiplayer = playerdata.instance()
	uiplayer.init(player)
	uiplayer.set_name(player.playerName)
	add_child(uiplayer)
