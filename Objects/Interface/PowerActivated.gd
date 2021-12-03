extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var copower: AudioStream = load("res://assets/Music/copower.mp3")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func power_activated(comander_texture : StreamTexture, power_name : String):
	var music_player = get_parent().get_parent().get_node("Music Player")
	get_child(1).get_node("Commander").set_texture(comander_texture)
	get_child(1).get_child(2).set_text(power_name)
	get_parent().get_parent().get_node("CanvasLayer/update-ui").visible = false
	$AnimationPlayer.play("fade")
	var previous_music = music_player.stream
	music_player.set_stream(copower)
	music_player.set_volume_db(-10)
	music_player.play()
	visible = true
	var t = Timer.new()
	t.set_wait_time(5)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	get_parent().get_parent().get_node("CanvasLayer/update-ui").visible = true
	music_player.set_stream(previous_music)	
	music_player.set_volume_db(-30)
	match power_name:
		"Viral Outbreak":
			music_player.set_volume_db(-15)
		"Cram Time":
			music_player.set_volume_db(-15)
	music_player.play()
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
