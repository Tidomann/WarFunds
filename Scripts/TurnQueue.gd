extends Node2D

class_name TurnQueue

var activePlayer



# Called when the node enters the scene tree for the first time.
func _ready():
	printOrder()
	pass # Replace with function body.

func initialize():
	var players = getPlayers()
	activePlayer = get_child(0)

func nextTurn():
	#yield(active_character.endTurn(), "completed")
	var newIndex : int = (activePlayer.get_index() + 1) % get_child_count()
	activePlayer = get_child(newIndex)
	startTurn(activePlayer)

func getPlayers():
	return get_children()

func printOrder():
	var output: String
	for player in get_children():
		output += player.name + ", "
	print(output)

func startTurn(player : Node2D):
	#iterate through units and set them to ready
	#generate income per property owned
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
