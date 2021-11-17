extends PopupMenu


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var fight_icon = load("res://assets/Sprites/UI/smallfistboy.svg")
var wait_icon = load("res://assets/Sprites/UI/down_arrow.png")
var cancel_icon = load("res://assets/Sprites/UI/cancel.png")
var power_icon = load("res://assets/Sprites/UI/power.png")
var end_turn_icon = load("res://assets/Sprites/UI/endturn.png")
var cap_icon = load("res://assets/Sprites/UI/flag.png")
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

func popup_menu(new_positon: Vector2, fight: bool, capt: bool, wait: bool, cancel : bool, power : bool, end_turn: bool) -> void:
	clear()
	if fight:
		add_icon_item(fight_icon,"Attack")
		#popup_exclusive = true
	if capt:
		add_icon_item(cap_icon,"Capture")
	if wait:
		add_icon_item(wait_icon,"Wait")
		#popup_exclusive = true
	if cancel:
		add_icon_item(cancel_icon,"Cancel")
		#popup_exclusive = true
	if power:
		add_icon_item(power_icon,"Power")
		#popup_exclusive = true
	if end_turn:
		add_icon_item(end_turn_icon,"End Turn")
		#popup_exclusive = true
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
	close()

func _unhandled_input(event: InputEvent) -> void:
	if self.visible:
		#if event is InputEventMouseButton && not get_rect().has_point(get_global_mouse_position()):
			#if event.is_action_released("ui_cancel"):
			#	close()
			#	get_tree().set_input_as_handled()
		if event.is_action_pressed("ui_cancel"):
			close()
			get_tree().set_input_as_handled()
			#if event.button_index == BUTTON_RIGHT:
			#	close()
		#elif event.is_action_pressed("ui_cancel"):
		#	close()


func _on_PopupMenu_gui_input(event):
	if self.visible:
		if event.is_action_pressed("ui_cancel"):
			close()
			#get_tree().set_input_as_handled()
