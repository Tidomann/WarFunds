extends AudioStreamPlayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var _turn_queue: TurnQueue = get_parent().get_node("TurnQueue")
var commanderMusic = {
	"Red Line" : "res://assets/Music/WinningtheRace.ogg",
	"Kronk" : "res://assets/Music/scrubslayer.mp3"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	var t = Timer.new()
	t.set_wait_time(0.2)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	var commander_name = get_parent().get_node("TurnQueue").activePlayer.commander.commanderName

	set_music(commander_name)
	
func set_music(commanderName : String) -> void:
	var audio_Stream: AudioStream = load(commanderMusic[commanderName])
	self.set_stream(audio_Stream)	
	self.set_volume_db(-30)
	play()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
