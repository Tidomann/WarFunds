extends Node2D

class_name TurnQueue

var activePlayer
export var gamegrid: Resource
var property_tilemap : TileMap
onready var audioStream = get_parent().get_node("Music Player")
onready var sound_manager = get_parent().get_node("GameBoard/SoundManager")
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
	#yield(active_character.endTurn(), "completed")
	var newIndex : int = (activePlayer.get_index() + 1) % get_child_count()
	activePlayer = get_child(newIndex)
	start_turn(activePlayer)
	emit_signal("turn_changed", activePlayer)
	audioStream.set_music(activePlayer.commander.commanderName)

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
