extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func new_turn_ui(comander_texture : StreamTexture, player_name : String, round_count):
	
	get_child(0).get_node("Commander").set_texture(comander_texture)
	get_child(0).get_child(1).set_text(player_name + "'s Turn")
	$Background/text2.set_text("Day  " + String(round_count))
	
	visible = true
	var t = Timer.new()
	t.set_wait_time(1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
