extends VBoxContainer

class_name UIPlayerData


var player : Node2D
var power_progress_bar
var player_name_bar
var player_turn_arrow
var funds_label
var income_label

# Called when the node enters the scene tree for the first time.
func _ready():
	#test()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func init(initplayer : Node2D):
	player = initplayer
	power_progress_bar = $PowerProgressBar
	player_name_bar = $PlayerNameBar
	player_turn_arrow = $PlayerNameBar/TurnArrow
	$PlayerNameBar/NameText.text = player.playerName
	$PlayerNameBar/ColouredGradient.modulate = Constants.get_colour(player.player_colour)
	$PlayerInfo/HBoxContainer/Leader/ColourBox.color = Constants.get_colour(player.player_colour)
	$PlayerInfo/HBoxContainer/Leader/LeaderPortrait.texture = player.commander.commander_portrait.get_texture()
	funds_label = $PlayerInfo/HBoxContainer/VBoxContainer/Funds/FundsText
	funds_label.text = String(player.funds)
	income_label = $PlayerInfo/HBoxContainer/VBoxContainer/Income/IncomeText
	income_label.text = "0"
	$PlayerInfo/HBoxContainer/Leader/LeaderPortrait.rect_scale.x = player.commander.commander_portrait.scale.x * 0.25
	$PlayerInfo/HBoxContainer/Leader/LeaderPortrait.rect_scale.y = player.commander.commander_portrait.scale.y * 0.25
	power_progress_bar.max_value = player.commander.maxPower
	power_progress_bar.texture_over = load(player.commander.stars_path)
	
