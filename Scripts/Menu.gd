extends Control

# Member variables. Examples:
# var a = 2
# var b = "text"
# this an example comment

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.load_game()
	$SceneTransitionRect/AnimationPlayer.play_backwards("Fade")
	randomize()
	$VBoxContainer/StartButton.grab_focus()
	OS.set_window_maximized(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_StartButton_pressed():
	$SoundStartButtonClick.play()
	$SceneTransitionRect/AnimationPlayer.play("Fade")
	yield($SceneTransitionRect/AnimationPlayer, "animation_finished")
	# Add a special intro when the game is finished?
	if Global.unlockedLevels[1] == true:
		get_tree().change_scene("res://Scenes/Select.tscn")
	else:
		Global.intro_dialogue = "res://Dialog/GameIntro.json"
		get_tree().change_scene("res://Scenes/Intro Dialog.tscn")

func _on_OptionsButton_pressed():
	$SoundStartButtonClick.play()
	$Kronk.visible = true
	$Sorry.visible = true
	pass # Replace with function body.

func _on_QuitButton_pressed():
	$SoundStartButtonClick.play()
	get_tree().quit()



func _on_Reset_pressed():
	$SoundStartButtonClick.play()
	$ConfirmationDialog.get_ok().text = "Yes"
	$ConfirmationDialog.get_cancel().text = "No"
	if not $ConfirmationDialog.popup():
		$ConfirmationDialog.visible = true


func _on_ConfirmationDialog_confirmed():
	$SoundStartButtonClick.play()
	Global.path = "res://Objects/Commanders/William.tscn"
	Global.intro_dialogue = "res://Dialog/GameIntro.json"
	Global.next_level = "res://Scenes/Select.tscn"
	Global.player_colour = Constants.COLOUR.BLUE
	Global.unlockedLeaders = [true,false,false,false,false,false,false,false]
	Global.discoveredLeaders = [true,false,false,false,false,false,false,false]
	Global.unlockedLevels = [true,false,false,false,false,false,false,false]
	Global.unlockedColours = [false,true,false,false,false,false]
	Global.save_game()
