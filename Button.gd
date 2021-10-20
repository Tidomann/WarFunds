extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var game  = $GameBoard
export (NodePath) var button_path
onready var button = get_node(button_path)

# Called when the node enters the scene tree for the first time.
func _ready():
	var button = Button.new()
	button.text = "Click me"
	button.connect("pressed", self, "_button_pressed")
	add_child(button)
	print(GameBoard)

func _button_pressed():
	print("Hello world!")
	game.pu()
	#for unit in GameBoard._units:
	#	unit.flip_turnReady()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
