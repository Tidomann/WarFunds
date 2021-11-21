extends Control

# Member variables. Examples:
# var a = 2
# var b = "text"
# this an example comment

# Called when the node enters the scene tree for the first time.
func _ready():
	$SceneTransitionRect/AnimationPlayer.play_backwards("Fade")
	randomize()
	$VBoxContainer/StartButton.grab_focus()
	OS.set_window_maximized(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StartButton_pressed():
	$SceneTransitionRect/AnimationPlayer.play("Fade")
	yield($SceneTransitionRect/AnimationPlayer, "animation_finished")
	get_tree().change_scene("res://Scenes/Intro Dialog.tscn")

func _on_OptionsButton_pressed():
	pass # Replace with function body.

func _on_QuitButton_pressed():
	get_tree().quit()

