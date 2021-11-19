extends Control

onready var buttons = get_node("ButtonList")

var _current_choice

func _ready():
	
	get_node(".").show()
	
	var m = 0
	for n in 8:
		var texture = load("res://assets/Sprites/DepartmentLeaders/emptycommander.png")
		
		var sprite = TextureButton.new()
		sprite.texture_normal = texture
		
		sprite.rect_scale = Vector2(0.4,0.4)
		
		if n%2 == 0:
			sprite.rect_position = Vector2(0,5+m*55)
		else: 
			sprite.rect_position = Vector2(50,5+m*55)
			m = m + 1
		$Commanders.add_child(sprite)
	
	# Creates the Level Select Buttons
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
		$ButtonList.add_child(button)
	pass # Replace with function body.

func _on_Button_pressed(id):
	_current_choice = id
	match id:
		1:
			# Shows the preview
			var texture = load("res://assets/Sprites/CommanderScreen/preview1.png")
			var sprite = Sprite.new()
			sprite.texture = texture			
			sprite.position = Vector2(245+106, 23+72)
			add_child(sprite)
			pass

func _on_Start_pressed():
	# Preload the level so we can move the commander into the next screen
	var scene = preload("res://Scenes/BattleMap.tscn").instance()
	scene.set_leader("res://Objects/Commander.tscn")
	get_node(".").hide()
	get_tree().get_root().add_child(scene)
