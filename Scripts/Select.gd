extends Control

var _current_choice

var emptycommander = load("res://assets/Sprites/DepartmentLeaders/emptycommander.png")
var disabledCommander = load("res://assets/Sprites/DepartmentLeaders/disabledcommander.png")

func _ready():
	$Start.disabled = true
	# Generate the Leader Portraits 
	var m = 0
	for n in 8:
		var texture
		#Determine if we have the leader
		if(n < Global.leaders.size()):
			texture = load(Global.leaders[n])
		else:
			texture = emptycommander
		#Connects the textures and resizes it
		var leaderButton = TextureButton.new()
		leaderButton.texture_normal = texture
		leaderButton.texture_disabled = disabledCommander
		var scale = 50.5/texture.get_size().x
		leaderButton.rect_scale = Vector2(scale, scale)
		if n%2 == 0:
			leaderButton.rect_position = Vector2(0,5+m*55)
		else: 
			leaderButton.rect_position = Vector2(50.5,5+m*55)
			m = m + 1
		if(Global.unlockedLeaders[n] == false):
			leaderButton.disabled = true
		leaderButton.connect("pressed", self, "_on_LeaderButton_pressed", [n+1])
		$Leaders.add_child(leaderButton)
	# Generate the Level Select Buttons
	for n in 8:
		var button = Button.new()
		button.text = "Level " + str(n+1)
		
		# Sets theme of the button
		var t = Theme.new()
		t.set_color("font_color_hover", "Button", Color(1,1,0))
		t.set_color("font_color", "Button", Color(1,1,1))
		t.set_color("font_color_pressed", "Button", Color(1,0,0))
		button.theme = t
		
		button.rect_position = Vector2(3, 3+n*25)
		button.rect_min_size = Vector2(95, 20)
		button.connect("pressed", self, "_on_Button_pressed", [n+1])
		button.set_toggle_mode(true)
		
		if(Global.unlockedLevels[n] == false):
			button.disabled = true
		$ButtonList.add_child(button)
	$Backgrounds/LeaderInfoBackground/ColorSelector.select(Global.player_colour)
	for n in Global.unlockedColours.size():
		$Backgrounds/LeaderInfoBackground/ColorSelector.set_item_disabled(n, !Global.unlockedColours[n])

func _on_Button_pressed(id):
	_current_choice = id
	for button in $ButtonList.get_children():
		if button.get_class() == "Button":
			if button.pressed && button != $ButtonList.get_child(id):
				button.set_pressed(false)
	#var path = "res://assets/Sprites/LeaderScreen/preview"+str(id)+".png"
	#var texture = load(path)
	#var sprite = Sprite.new()
	#sprite.texture = texture			
	#sprite.position = Vector2(245+106, 20+72)
	#add_child(sprite)
	$SoundSelect.play()
			
func _on_LeaderButton_pressed(id):
	if(id < Global.leaders.size()+1):
		Global.path = Global.leaderPath[id-1]
		for child in $Leaders.get_children():
			child.modulate = Color(1,1,1)
		$Leaders.get_child(id).modulate = Color(1.0,5.0,1.0)
		$Start.disabled = false
		$LeaderDetails.text = Global.leadersDesc[id-1]
	$SoundSelect.play()
	
func _on_Start_pressed():
	if(!(_current_choice == null)):
# warning-ignore:return_value_discarded
		$SoundSelect.play()
		$MoveOut.play()
		$SceneTransitionRect/AnimationPlayer.play("Fade")
		yield($SceneTransitionRect/AnimationPlayer, "animation_finished")
		Global.intro_dialogue = Global.level_intros[_current_choice-1]
		Global.next_level = Global.levels[_current_choice-1]
		get_tree().change_scene(Global.intro_scenes[_current_choice-1])



func _on_ColorSelector_item_selected(index):
	match index:
		#red
		0:
			Global.player_colour = Constants.COLOUR.RED
		#blue
		1:
			Global.player_colour = Constants.COLOUR.BLUE
		2:
			Global.player_colour = Constants.COLOUR.GREEN
		3:
			Global.player_colour = Constants.COLOUR.YELLOW
		4:
			Global.player_colour = Constants.COLOUR.CYAN
		5:
			Global.player_colour = Constants.COLOUR.PURPLE
	pass # Replace with function body.
