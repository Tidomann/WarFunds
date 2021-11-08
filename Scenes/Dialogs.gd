extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$Intro.dialogPath = "res://Dialog/Dialog1.json"
	$Intro.start_dialog()


#####make a signal here
#	if $Intro.finished():
#		print("finished")
#		get_tree().change_scene("res://Scenes/BattleMap.tscn")
#	else:
#		print("not done")	



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
