extends Control

var _current_choice

var emptycommander = load("res://assets/Sprites/DepartmentLeaders/emptycommander.png")
var disabledCommander = load("res://assets/Sprites/DepartmentLeaders/disabledcommander.png")

func _ready():
	Global.load_game()
	$Start.disabled = true
	# Generate the Leader Portraits 
	var m = 0
	for n in 8:
		var texture
		var texture_focused
		var texture_discovered
		var texture_discovered_focused
		#Determine if we have the leader
		if(n < Global.leaders.size()):
			texture = load(Global.leaders[n])
			texture_focused = load(Global.leaders_focused[n])
			texture_discovered = load(Global.leaders_discovered[n])
			texture_discovered_focused = load(Global.leaders_discovered_focused[n])
		else:
			texture = emptycommander
		# Create he leader button
		var leaderButton = TextureButton.new()
		if texture == emptycommander:
			leaderButton.set_focus_mode(0)
		if(n < Global.leaders.size()):
			if Global.unlockedLeaders[n]:
				leaderButton.texture_normal = texture
				leaderButton.texture_focused = texture_focused
			elif Global.discoveredLeaders:
				leaderButton.texture_normal = texture_discovered
				leaderButton.texture_focused = texture_discovered_focused
		if(n < Global.leaders.size()):
			leaderButton.texture_disabled = emptycommander
			# used to be disabled commander but using empty commander "?"
			#leaderButton.texture_disabled = disabledCommander
		else:
			leaderButton.texture_disabled = emptycommander
		# Disable the commanders that are not unlocked
		if(Global.unlockedLeaders[n] == false && Global.discoveredLeaders[n] == false):
			leaderButton.disabled = true
			leaderButton.texture_focused = null
			leaderButton.set_focus_mode(0)
		# Rescale the images
		if leaderButton.disabled == false:
			var scale = 50.5/texture.get_size().x
			leaderButton.rect_scale = Vector2(scale, scale)
		else:
			var scale = 50.5/emptycommander.get_size().x
			#var scale = 50.5/disabledCommander.get_size().x
			leaderButton.rect_scale = Vector2(scale, scale)
		if n%2 == 0:
			leaderButton.rect_position = Vector2(0,5+m*55)
		else: 
			leaderButton.rect_position = Vector2(50.5,5+m*55)
			m = m + 1
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
	$ButtonList.get_children()[1].grab_focus()
	$ButtonList.get_children()[1].emit_signal("pressed")
	$ButtonList.get_children()[1].pressed = true

func _on_Button_pressed(id):
	if _current_choice == id:
		$ButtonList.get_child(id).set_pressed(true)
		return
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
		if(Global.unlockedLeaders[id-1] || Global.discoveredLeaders[id-1]):
			if Global.unlockedLeaders[id-1]:
				Global.path = Global.leaderPath[id-1]
				# Reset the colors of all the buttons
				for child in $Leaders.get_children():
					child.modulate = Color(1,1,1)
				# Color this one selected
				$Leaders.get_child(id).modulate = Color(1.0,5.0,1.0)
				$Start.disabled = false
				$LeaderDetails.clear()
				$LeaderDetails.append_bbcode(Global.leadersDesc[id-1])
				$SoundSelect.play()
			else:
				$LeaderDetails.clear()
				$LeaderDetails.append_bbcode(Global.leadersDesc[id-1])
		else:
			return

func _on_Start_pressed():
	if(!(_current_choice == null)):
# warning-ignore:return_value_discarded
		$SoundSelect.play()
		$MoveOut.play()
		Global.intro_dialogue = Global.level_intros[_current_choice-1]
		Global.next_level = Global.levels[_current_choice-1]
		Global.save_game()
		$SceneTransitionRect/AnimationPlayer.play("Fade")
		yield($SceneTransitionRect/AnimationPlayer, "animation_finished")
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
