extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# this is a useless comment

# Called when the node enters the scene tree for the first time.
func _ready():
	var devMap = Array()
	devMap.resize(150)
	for a in 150:
		devMap.append(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
