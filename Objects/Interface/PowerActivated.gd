extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func power_activated(comander_texture : StreamTexture, power_name : String):
	get_child(1).get_node("Commander").set_texture(comander_texture)
	get_child(1).get_child(2).set_text(power_name)
	$AnimationPlayer.play("fade")
	visible = true
	var t = Timer.new()
	t.set_wait_time(4)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
