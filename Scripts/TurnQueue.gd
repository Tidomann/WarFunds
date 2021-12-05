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
	var newIndex : int = (activePlayer.get_index() + 1) % get_child_count()
	if newIndex == 0:
		round_count += 1
	activePlayer = get_child(newIndex)
	if activePlayer.computerAI:
		var t = Timer.new()
		t.set_wait_time(0.08)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		cursor.deactivate(true)
		t.queue_free()
	#Auto fill power line
	#activePlayer.commander.setPowerFilled()
	start_turn(activePlayer)
	emit_signal("turn_changed", activePlayer)
	audioStream.set_music(activePlayer.commander.commanderName)
	turn_ui.new_turn_ui(activePlayer.commander.commander_portrait.texture, activePlayer.playerName, round_count)
	yield(check_new_turn_dialogue(round_count, activePlayer), "completed")
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
			pass
		1:
			match turn_count:
				1:
					if not inPlayer.computerAI:
						#this is the players first turn
						pass
					else:
						#this is the computer first turn
						var t = Timer.new()
						t.set_wait_time(2)
						t.set_one_shot(true)
						self.add_child(t)
						t.start()
						yield(t, "timeout")
						t.queue_free()
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = false
						var dialogue_node = gamegrid.battlemap.get_node("CanvasLayer/DialogBox")
						dialogue_node.dialogPath = "res://Dialog/Level1Comp1.json"
						gamegrid.battlemap.get_node("GameBoard/Cursor").deactivate(true)
						dialogue_node.start_dialog()
						yield(dialogue_node, "dialog_finished")
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = true
		2:
			match turn_count:
				1:
					if not inPlayer.computerAI:
						#this is the players first turn
						pass
					else:
						#this is the computer first turn
						var t = Timer.new()
						t.set_wait_time(2)
						t.set_one_shot(true)
						self.add_child(t)
						t.start()
						yield(t, "timeout")
						t.queue_free()
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = false
						var dialogue_node = gamegrid.battlemap.get_node("CanvasLayer/DialogBox")
						dialogue_node.dialogPath = "res://Dialog/Level2Comp1.json"
						gamegrid.battlemap.get_node("GameBoard/Cursor").deactivate(true)
						dialogue_node.start_dialog()
						yield(dialogue_node, "dialog_finished")
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = true
		3:
			match turn_count:
				1:
					if not inPlayer.computerAI:
						#this is the players first turn
						pass
					else:
						#this is the computer first turn
						var t = Timer.new()
						t.set_wait_time(2)
						t.set_one_shot(true)
						self.add_child(t)
						t.start()
						yield(t, "timeout")
						t.queue_free()
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = false
						var dialogue_node = gamegrid.battlemap.get_node("CanvasLayer/DialogBox")
						dialogue_node.dialogPath = "res://Dialog/Level3Comp1.json"
						gamegrid.battlemap.get_node("GameBoard/Cursor").deactivate(true)
						dialogue_node.start_dialog()
						yield(dialogue_node, "dialog_finished")
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = true
				2:
					if not inPlayer.computerAI:
						#this is the players 2nd turn
						gamegrid.battlemap.get_node("GameBoard/Cursor").deactivate(true)
						var t = Timer.new()
						t.set_wait_time(2)
						t.set_one_shot(true)
						self.add_child(t)
						t.start()
						yield(t, "timeout")
						t.queue_free()
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = false
						var dialogue_node = gamegrid.battlemap.get_node("CanvasLayer/DialogBox")
						dialogue_node.dialogPath = "res://Dialog/Level3Player2.json"
						dialogue_node.start_dialog()
						yield(dialogue_node, "dialog_finished")
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = true
						gamegrid.battlemap.get_node("GameBoard/Cursor").activate()
					else:
						#this is the computer first turn
						pass
				3:
					if not inPlayer.computerAI:
						#this is the players 3rd turn
						gamegrid.battlemap.get_node("GameBoard/Cursor").deactivate(true)
						var t = Timer.new()
						t.set_wait_time(2)
						t.set_one_shot(true)
						self.add_child(t)
						t.start()
						yield(t, "timeout")
						t.queue_free()
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = false
						var dialogue_node = gamegrid.battlemap.get_node("CanvasLayer/DialogBox")
						dialogue_node.dialogPath = "res://Dialog/Level3Player3.json"
						dialogue_node.start_dialog()
						yield(dialogue_node, "dialog_finished")
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = true
						gamegrid.battlemap.get_node("GameBoard/Cursor").activate()
					else:
						#this is the computer first turn
						pass
			pass
		4:
			match turn_count:
				1:
					if not inPlayer.computerAI:
						#this is the players first turn
						pass
					else:
						#this is the computer first turn
						var t = Timer.new()
						t.set_wait_time(2)
						t.set_one_shot(true)
						self.add_child(t)
						t.start()
						yield(t, "timeout")
						t.queue_free()
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = false
						var dialogue_node = gamegrid.battlemap.get_node("CanvasLayer/DialogBox")
						dialogue_node.dialogPath = "res://Dialog/Level4Comp1.json"
						gamegrid.battlemap.get_node("GameBoard/Cursor").deactivate(true)
						dialogue_node.start_dialog()
						yield(dialogue_node, "dialog_finished")
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = true
		5:
			match turn_count:
				1:
					if not inPlayer.computerAI:
						#this is the players first turn
						pass
					else:
						#this is the computer's first rurn
						var t = Timer.new()
						t.set_wait_time(2)
						t.set_one_shot(true)
						self.add_child(t)
						t.start()
						yield(t, "timeout")
						t.queue_free()
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = false
						var dialogue_node = gamegrid.battlemap.get_node("CanvasLayer/DialogBox")
						dialogue_node.dialogPath = "res://Dialog/Level5Comp1.json"
						gamegrid.battlemap.get_node("GameBoard/Cursor").deactivate(true)
						dialogue_node.start_dialog()
						yield(dialogue_node, "dialog_finished")
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = true
		7:
			match turn_count:
				1:
					if inPlayer.computerAI && inPlayer.commander.commanderName == "General Ghani":
						#this is the computer's first rurn
						var t = Timer.new()
						t.set_wait_time(2)
						t.set_one_shot(true)
						self.add_child(t)
						t.start()
						yield(t, "timeout")
						t.queue_free()
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = false
						var dialogue_node = gamegrid.battlemap.get_node("CanvasLayer/DialogBox")
						dialogue_node.dialogPath = "res://Dialog/Level7Comp1.json"
						gamegrid.battlemap.get_node("GameBoard/Cursor").deactivate(true)
						dialogue_node.start_dialog()
						yield(dialogue_node, "dialog_finished")
						gamegrid.battlemap.get_node("CanvasLayer/update-ui").visible = true
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
