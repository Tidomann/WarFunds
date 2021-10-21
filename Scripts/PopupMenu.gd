extends PopupMenu


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var fight_icon = load("res://assets/Sprites/UI/smallfistboy.svg")
var wait_icon = load("res://assets/Sprites/UI/down_arrow.png")
var end_turn_icon = load("res://assets/Sprites/UI/return.png")
signal Wait
signal Attack
# Called when the node enters the scene tree for the first time.
func _ready():
	# TODO: Cry a lil then finish this 
	connect('Wait',get_parent().get_node("GameBoard"), "wait_selected")
	#self.rect_global_position = Vector2(256,256)
	pass
func popup_menu(new_positon: Vector2, fight: bool, wait: bool, end_turn: bool) -> void:
	clear()
	
	add_icon_item(wait_icon,'Wait')

	self.rect_global_position = new_positon+Vector2(16,-16)
	popup()
	#self.grab_focus()
	var a = InputEventKey.new()
	a.scancode = KEY_DOWN
	a.pressed = true # change to false to simulate a key release
	Input.parse_input_event(a)
	


	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _on_PopupMenu_id_pressed(id):
	emit_signal(self.get_item_text(id))
