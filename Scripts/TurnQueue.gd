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
var round_count := 1
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
	if newIndex == 0:
		round_count += 1
	activePlayer = get_child(newIndex)
	start_turn(activePlayer)
	emit_signal("turn_changed", activePlayer, round_count)
	audioStream.set_music(activePlayer.commander.commanderName)
	turn_ui.new_turn_ui(activePlayer.commander.commander_portrait.texture, activePlayer.playerName, round_count)
	check_new_turn_dialogue(round_count, activePlayer)
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
	var income = gamegrid.start_turn_income(player)
	player.addFunds(income)
	player.addPower(income*0.2)
	if player.commander.canUsePower():
				sound_manager.playsound("PowerReady")

func check_new_turn_dialogue(turn_count: int, inPlayer: Node2D) -> void:
	match gamegrid.battlemap.level_number:
		0:
			match turn_count:
				1:
					if not inPlayer.computerAI:
						#this is the players first turn
						pass
					else:
						#this is the computers first turn
						pass
			pass
		1:
			pass
		2:
			pass
		3:
			pass
		4:
			pass
	var t = Timer.new()
	t.set_wait_time(0.08)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	t.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
