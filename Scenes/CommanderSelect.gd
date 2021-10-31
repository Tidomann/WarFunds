extends Control

onready var buttons = get_node("ButtonList")
onready var commanders = get_node("Commanders")


func _ready():
	var m = 0
	for n in 8:
		var texture = ImageTexture.new()
		var image = Image.new()
		image.load("res://assets/Sprites/DepartmentLeaders/emptycommander.png")
		texture.create_from_image(image)
		var sprite = Sprite.new()
		sprite.texture = texture
		sprite.scale = Vector2(0.4, 0.4)
		if n%2 == 0:
			sprite.position = Vector2(25,30+m*55)
		else: 
			sprite.position = Vector2(25+50,30+m*55)
			m = m + 1
		commanders.add_child(sprite)
	for n in 8:
		var button = Button.new()
		button.text = "Level " + str(n+1)
		button.rect_position = Vector2(3, 3+n*25)
		button.rect_min_size = Vector2(102, 20)
		button.connect("pressed", self, "_on_Button_pressed", [n+1])
		buttons.add_child(button)
	pass # Replace with function body.


func _on_Button_pressed(id):
	match id:
		1:
			var texture = ImageTexture.new()
			var image = Image.new()
			image.load("res://assets/Sprites/CommanderScreen/preview1.png")
			texture.create_from_image(image)
			var sprite = Sprite.new()
			sprite.texture = texture
			sprite.position = Vector2(106, 77-5)
			$Preview.add_child(sprite)
			pass
	print(id)



