extends VBoxContainer


var player : Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	#test()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func init(initplayer : Node2D):
	player = initplayer
	$PlayerNameBar/NameText.text = player.playerName
	$PlayerNameBar/ColouredGradient.modulate = Constants.get_colour(player.player_colour)
	$PlayerInfo/HBoxContainer/Leader/ColourBox.color = Constants.get_colour(player.player_colour)
	$PlayerInfo/HBoxContainer/Leader/LeaderPortrait.texture = player.commander.commander_portrait.get_texture()
	$PlayerInfo/HBoxContainer/VBoxContainer/Funds/FundsText.text = String(player.funds)
	$PlayerInfo/HBoxContainer/VBoxContainer/Income/IncomeText.text = "0"
	$PowerProgressBar.max_value = player.commander.maxPower
	$PowerProgressBar.texture_over = load(player.commander.stars_path)
	print(player.commander.maxPower)

func test():
	$PlayerNameBar/NameText.text = "Test name"
	print($PlayerNameBar/ColouredGradient.modulate)
	$PlayerNameBar/ColouredGradient.modulate = Constants.get_colour((Constants.COLOUR.RED))
	$PlayerInfo/HBoxContainer/Leader/ColourBox.color = Constants.get_colour((Constants.COLOUR.RED))
	$PlayerInfo/HBoxContainer/Leader/LeaderPortrait.texture = load("res://assets/Sprites/DepartmentLeaders/Kronk/Konkneutral.png")
	$PlayerInfo/HBoxContainer/VBoxContainer/Funds/FundsText.text = "1234"
	$PlayerInfo/HBoxContainer/VBoxContainer/Income/IncomeText.text = "4321"
	$PowerProgressBar.max_value = 2700
	$PowerProgressBar.texture_over = load("res://assets/Sprites/UI/UICommander/PowerBar/3stars.png")
