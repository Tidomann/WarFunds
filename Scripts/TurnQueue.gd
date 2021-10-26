extends Node2D

class_name TurnQueue

var activePlayer



# Called when the node enters the scene tree for the first time.
func _ready():
	initialize()

func initialize():
	activePlayer = get_child(0)

func nextTurn():
	#yield(active_character.endTurn(), "completed")
	var newIndex : int = (activePlayer.get_index() + 1) % get_child_count()
	activePlayer = get_child(newIndex)
	start_turn(activePlayer)

func getPlayers():
	return get_children()

func printOrder():
	var output := ""
	for player in get_children():
		output += player.name + ", "
	print(output)

func start_turn(player : Node2D):
	activePlayer.commander.used_power = false
	#generate income per property owned

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
