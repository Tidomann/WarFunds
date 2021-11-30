extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var playerdata = load("res://Objects/Interface/UIPlayerData.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func add_player(player : Node2D):
	var uiplayer = playerdata.instance()
	uiplayer.init(player)
	uiplayer.set_name(player.playerName)
	add_child(uiplayer)

func income_changed(player : Node2D, income : int) -> void:
	for uiPlayerData in self.get_children():
		if uiPlayerData.player == player:
			uiPlayerData.income_label.text = String(income)


func power_changed(playerOwner, power, maxPower):
	for uiPlayerData in self.get_children():
		if uiPlayerData.player == playerOwner:
			uiPlayerData.power_progress_bar.value = power
			uiPlayerData.power_progress_bar.max_value = maxPower


func _on_TurnQueue_turn_changed(activePlayer):
	for uiPlayerData in self.get_children():
		if uiPlayerData.player == activePlayer:
			uiPlayerData.player_turn_arrow.visible = true
		else:
			uiPlayerData.player_turn_arrow.visible = false


func funds_changed(self_referance, funds):
	for uiPlayerData in self.get_children():
		if uiPlayerData.player == self_referance:
			uiPlayerData.funds_label.text = String(funds)
