extends PopupMenu


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var fight_icon = load("res://assets/Sprites/UI/smallfistboy.svg")
var wait_icon = load("res://assets/Sprites/UI/down_arrow.png")
var end_turn_icon = load("res://assets/Sprites/UI/endturn.png")
signal selection
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func close() -> void:
	clear()
	hide()
	self.set_as_minsize()
	#margin_bottom = margin_top + 7
	#margin_right = margin_left + 15

func popup_menu(new_positon: Vector2, fight: bool, wait: bool, end_turn: bool) -> void:
	clear()
	if fight:
		add_icon_item(fight_icon,"Attack")
		popup_exclusive = true
	if wait:
		add_icon_item(wait_icon,"Wait")
		popup_exclusive = true
	if end_turn:
		add_icon_item(end_turn_icon,"End Turn")
		popup_exclusive = false
	self.rect_global_position = new_positon+Vector2(16,-16)
	self.set_as_minsize()
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
	emit_signal("selection", self.get_item_text(id))
	clear()

func _unhandled_input(event: InputEvent) -> void:
	if self.visible:
		if event is InputEventMouseButton:
			if event.button_index == BUTTON_RIGHT:
				emit_signal("selection", "Cancel")
				get_tree().set_input_as_handled()
		elif event.is_action_pressed("ui_cancel"):
			emit_signal("selection", "Cancel")
			get_tree().set_input_as_handled()


func _on_PopupMenu_popup_hide():
	emit_signal("selection", "Cancel")
	clear()
