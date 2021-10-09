extends Node2D

class_name TurnQueue

var activeCharacter



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize():
	var players = getPlayers()
	activeCharacter = get_child(0)

func nextTurn():
	#yield(active_character.endTurn(), "completed")
	var newIndex : int = (activeCharacter.get_index() + 1) % get_child_count()
	activeCharacter = get_child(newIndex)

func getPlayers():
	return get_children()

func printOrder():
	var output: String
	for player in get_children():
		output += player.name + ", "
	print(output)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
