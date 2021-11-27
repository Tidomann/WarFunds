extends Node2D

class_name TurnQueue

var activePlayer
export var gamegrid: Resource
var property_tilemap : TileMap
onready var audioStream = get_parent().get_node("Music Player")
onready var turn_ui = get_parent().get_node("CanvasLayer/NewTurnUi")
onready var sound_manager = get_parent().get_node("GameBoard/SoundManager")
onready var ai_control = get_parent().get_node("AIControl")
onready var cursor = get_parent().get_node("GameBoard/Cursor")
signal turn_changed(activePlayer)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func initialize(battlemap):
	gamegrid = battlemap.gamegrid
	property_tilemap = battlemap.get_node("PropertyTiles")
	activePlayer = get_child(0)
	emit_signal("turn_changed", activePlayer)
	start_turn(activePlayer)

func nextTurn():
	cursor.activate()
	#yield(active_character.endTurn(), "completed")
	var newIndex : int = (activePlayer.get_index() + 1) % get_child_count()
	activePlayer = get_child(newIndex)
	start_turn(activePlayer)
	emit_signal("turn_changed", activePlayer)
	audioStream.set_music(activePlayer.commander.commanderName)
	turn_ui.new_turn_ui(activePlayer.commander.commander_portrait.texture, activePlayer.playerName)
	if activePlayer.computerAI:
		ai_control.take_computer_turn(activePlayer)
		var t = Timer.new()
		t.set_wait_time(0.08)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		cursor.deactivate(true)
		t.queue_free()
		

func getPlayers():
	return get_children()

func printOrder():
	var output := ""
	for player in get_children():
		output += player.name + ", "
	print(output)

func start_turn(player : Node2D):
	player.commander.used_power = false
	#generate income per property owned
	var now_max_power = not player.commander.canUsePower()
	var income = gamegrid.start_turn_income(player)
	player.addFunds(income)
	player.addPower(income*0.2)
	if now_max_power && player.commander.canUsePower():
				sound_manager.playsound("PowerReady")
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
