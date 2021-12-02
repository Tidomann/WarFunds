extends Node2D

# Member Variables
export var level_number = 0
# Variables that represent the map boundaries
export var fog_map := false
export var victory_eliminate := true
export var victory_hq := true
export var victory_property := false
export var property_goal := 15

export(int) var xMin
export(int) var xMax
export(int) var yMin
export(int) var yMax
export var gamegrid: Resource
onready var _unit_overlay: UnitOverlay = $GameBoard/UnitOverlay
onready var _units_node = $GameBoard/Units

# Called when the node enters the scene tree for the first time.
func _ready():
	$"CanvasLayer/update-ui".visible = false
	$CanvasLayer/CommanderUI.visible = false
	# Load the Game Data
	gamegrid.initialize(self)
	# Initialize the Humans Commander to be the chosen commander from Select
	# or default to William
	for child in $TurnQueue/Human.get_children():
		$TurnQueue/Human.remove_child(child)
		child.free()
	var leader = load(Global.path)
	var player = $TurnQueue/Human
	player.player_colour = Global.player_colour
	player.add_child(leader.instance())
	var commander = $TurnQueue/Human.get_child(0)
	player.commander = commander
	commander.playerOwner = player
	commander.connect("power_changed", $CanvasLayer/CommanderUI, "power_changed")

	
	# Setup the Map now that proper commander is in place
	setup_tiles()
	setup_cursor()
	$GameBoard/Cursor.deactivate(true)

	# Set the positioning and the correct unit sprite for the commanders
	for child in $GameBoard/Units.get_children():
		var unit := child as Unit
		if not unit:
			continue
		unit.update_position()
		unit.army_color_set()
		unit.update_health()
		unit.set_flip()

	#Now that the proper commander is in place, set up the turnqueue
	
	for child in $TurnQueue.get_children():
		$CanvasLayer/CommanderUI.add_player(child)
		$CanvasLayer/CommanderUI.income_changed(child, gamegrid.calculate_income(child))
		child.addPower(0)
	$TurnQueue.initialize(self)
	$Devtiles.visible = false
	$AIControl.init(self)
	#Start of battle dialog
	$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level0Intro.json"
	match level_number:
		0:
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level0Intro.json"
		1:
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level1Start.json"
		2:
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level2Start.json"
		3:
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level3Start.json"
		4:
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level4Start.json"
		5:
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level5Start.json"
		6:
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level6Start.json"
	$CanvasLayer/DialogBox.start_dialog()
	#$"Music Player".set_stream(load("res://assets/Music/DialogBackgroundMusic.mp3"))
	#$"Music Player".set_volume_db(-30)
	#$"Music Player".play()
	#$"Music Player".set_music($TurnQueue.activePlayer.commander.commanderName)
	yield($CanvasLayer/DialogBox, "dialog_finished")
	$"CanvasLayer/update-ui".visible = true
	$CanvasLayer/CommanderUI.visible = true
	#$"Music Player".set_music($TurnQueue.activePlayer.commander.commanderName)
	$GameBoard/Cursor.activate()
	#var t = Timer.new()
	#t.set_wait_time(1)
	#t.set_one_shot(true)
	#self.add_child(t)
	#t.start()
	#yield(t, "timeout")
	#victory()


# Uses the Devtiles tilemap to create the appropriate map on the RenderedTiles
# tilemap
func setup_tiles():
	# Setup Terrain Tiles
	var tileArray = $Devtiles.get_used_cells()
	for cell in tileArray:
		var tileIndex = $RenderedTiles.tile_set.find_tile_by_name(
			$Devtiles.tile_set.tile_get_name($Devtiles.get_cellv(cell)))
		$RenderedTiles.set_cellv(cell, tileIndex)
		if tileIndex == Constants.TILE.SEA || tileIndex == Constants.TILE.ROAD || tileIndex == Constants.TILE.RIVER:
			$RenderedTiles.update_bitmask_area(cell)
	# Setup Property Tiles
	var propertyArray = $Devproperty.get_used_cells()
	var players = $TurnQueue.get_children()
	for cell in propertyArray:
		var temptilevalue = $Devproperty.get_cellv(cell)
		var tempplayer = int(temptilevalue / 6.0)
		var property_type = temptilevalue % 6
		if tempplayer == 0:
			if property_type >= 1:
				$PropertyTiles.set_cellv(cell, 64+property_type)
			else:
				$PropertyTiles.set_cellv(cell, 60)
		else:
			if tempplayer > players.size():
				if property_type > 1:
					$PropertyTiles.set_cellv(cell, 64+property_type)
				else:
					$PropertyTiles.set_cellv(cell, 60)
			else:
				var property_owner = players[tempplayer-1]
				if property_type == 0:
					#Find the right HQ building
					var army_type = property_owner.commander.army_type
					var army_array_value
					match army_type:
						Constants.ARMY.ENGINEERING:
							army_array_value = 3
						Constants.ARMY.COSC:
							army_array_value = 1
						Constants.ARMY.BIOLOGY:
							army_array_value = 4
						Constants.ARMY.FINANCE:
							army_array_value = 2
						Constants.ARMY.NURSING:
							army_array_value = 4
						Constants.ARMY.BANKTANIA:
							army_array_value = 0
					var property_tile_index = 10*property_owner.player_colour
					#print(property_tile_index)
					property_tile_index += army_array_value
					#print(property_tile_index)
					$PropertyTiles.set_cellv(cell, property_tile_index)
				else:
					#Find the right property building
					var property_tile_index = 10*property_owner.player_colour
					property_tile_index += 4+property_type
					$PropertyTiles.set_cellv(cell, property_tile_index)
	$Devproperty.visible = false
# Initializes the cursor using the cursor.init function so the cursor knows
# what tiles exist in the map
func setup_cursor():
	$GameBoard/Cursor.init($Devtiles)
	$GameBoard/CombatCursor.init($Devtiles)
		

func Xmin() -> int:
	return xMin
	
func Xmax() -> int:
	return xMax
	
func Ymin() -> int:
	return yMin
	
func Ymax() -> int:
	return yMax

func set_property(cell : Vector2, player : Node2D):
	var temptilevalue = $PropertyTiles.get_cellv(cell)
	var property_type = temptilevalue % 10
	if player == null:
		$PropertyTiles.set_cellv(cell, 60+property_type)
	else:
		if property_type >= 0 && property_type <= 4:
			#Find the right HQ building
			var army_array_value
			match player.commander.army_type:
				Constants.ARMY.ENGINEERING:
					army_array_value = 3
				Constants.ARMY.COSC:
					army_array_value = 1
				Constants.ARMY.BIOLOGY:
					army_array_value = 4
				Constants.ARMY.FINANCE:
					army_array_value = 2
				Constants.ARMY.NURSING:
					army_array_value = 4
				Constants.ARMY.BANKTANIA:
					army_array_value = 0
			var property_tile_index = 10*player.player_colour
			#print(property_tile_index)
			property_tile_index += army_array_value
			#print(property_tile_index)
			$PropertyTiles.set_cellv(cell, property_tile_index)
		else:
			#Find the right property building
			var property_tile_index = 10*player.player_colour
			property_tile_index += property_type
			$PropertyTiles.set_cellv(cell, property_tile_index)

func game_finished(human : Node2D) -> bool:
	var property_array = gamegrid.get_properties()
	var players = $TurnQueue.get_children()
	var enemies := []
	var allies := []
	for player in players:
		if player.team != human.team:
			enemies.append(player)
		else:
			allies.append(player)
	# A player is eliminated if they own no units
	# all production buildings has an enemy blocking it
	if victory_eliminate:
		for player in players:
			# Assume player is eliminated
			player.defeated = true
			# if the player has units they are not defeated
			if gamegrid.get_players_units(player).size() > 0:
				player.defeated = false
			else:
				# check if the map has proprties
				if not property_array.empty():
					for property in property_array:
						if property.playerOwner == player:
							# if the property they own is a production building
							if property.property_referance == Constants.PROPERTY.BASE || \
							property.property_referance == Constants.PROPERTY.AIRPORT || \
							property.property_referance == Constants.PROPERTY.PORT:
								# the property is not occupied by a unit
								if not gamegrid.is_occupied(property.cell):
									player.defeated = false
								# the property is occupied by a unit
								else:
									# that unit is on the same team as the player
									if gamegrid.get_unit(property.cell).playerOwner.team == player.team:
										player.defeated = false
	# A player is eliminated if they don't own an HQ
	if victory_hq:
		for player in players:
			# Skip if the player was previously eliminated
			if player.defeated == true:
				continue
			# Assume player is eliminated
			player.defeated = true
			for property in property_array:
				if property.playerOwner == player && property.property_referance == Constants.PROPERTY.HQ:
					player.defeated = false
	# If a player controls the required number of properties
	# the game is over
	if victory_property:
		for player in players:
			var property_count = 0
			for property in property_array:
				if property.playerOwner == player:
					property_count += 1
			if property_count >= property_goal:
				return true
	# Check all allies or all enemies are eliminated
	# Assume allies are defeated
	var team_defeated = true
	for player in allies:
		if not player.defeated:
			team_defeated = false
	if team_defeated:
		return team_defeated
	# Assume enemies are defeated
	team_defeated = true
	for player in enemies:
		if not player.defeated:
			team_defeated = false
	# Remove Eliminated players from the game
	for player in players:
		if player.defeated:
			# Turn all their properties to neutral
			for property in property_array:
				if property.playerOwner == player:
					property.playerOwner = null
					set_property(property.cell, null)
			# Delete their units
			var unit_array = gamegrid.get_players_units(player)
			if not unit_array.empty():
				for unit in unit_array:
					# remove the unit from the grid data
					gamegrid.array[gamegrid.as_index(unit.cell)].unit = null
					# delete the unit node
					unit.queue_free()
			# Remove the Player from the UI
			for player_ui in $CanvasLayer/CommanderUI.get_children():
				if player_ui.player == player:
					player_ui.queue_free()
			# Remove the player (both from the turn order and the node)
			for playernode in $TurnQueue.get_children():
				if playernode == player:
					if $TurnQueue.activePlayer == player:
						$TurnQueue.nextTurn()
					player.queue_free()
	return team_defeated

func is_victory(human : Node2D) -> bool:
	var property_array = gamegrid.get_properties()
	var players = $TurnQueue.get_children()
	var enemies := []
	var allies := []
	for player in players:
		if player.team != human.team:
			enemies.append(player)
		else:
			allies.append(player)
	if enemies.empty():
		return true
	var allies_defeated = true
	for player in allies:
		if not player.defeated:
			allies_defeated = false
	if allies_defeated:
		return false
	# Assume enemies are defeated
	var enemies_defeated = true
	for player in enemies:
		if not player.defeated:
			enemies_defeated = false
	if enemies_defeated:
		return true
	if victory_property:
		for player in players:
			var property_count = 0
			for property in property_array:
				if property.playerOwner == player:
					property_count += 1
			if property_count >= property_goal:
				return allies.has(player)
	return false

func victory() -> void:
	print("Victory")
	$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level0Victory.json"
	$"CanvasLayer/update-ui".visible = false
	$CanvasLayer/CommanderUI.visible = false
	match level_number:
		0:
			for n in 8:
				Global.unlockedLevels[n] = true
			for n in 8:
				Global.unlockedLeaders[n] = true
			Global.save_game()
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level0Victory.json"
		1:
			Global.unlockedLevels[1] = true
			Global.save_game()
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level1Victory.json"
		2:
			Global.unlockedLevels[2] = true
			Global.save_game()
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level2Victory.json"
		3:
			Global.unlockedLevels[3] = true
			Global.save_game()
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level3Victory.json"
		4:
			var previously_beaten = Global.unlockedLeaders[1]
			Global.unlockedLevels[4] = true
			Global.unlockedLeaders[1] = true
			Global.unlockedColours[3] = true
			Global.save_game()
			if not previously_beaten:
				$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level4Victory1.json"
				$CanvasLayer/DialogBox.start_dialog()
				$GameBoard/Cursor.deactivate(true)
				yield($CanvasLayer/DialogBox, "dialog_finished")
				var t = Timer.new()
				t.set_wait_time(0.05)
				t.set_one_shot(true)
				self.add_child(t)
				t.start()
				yield(t, "timeout")
				$"Music Player".set_stream(load("res://assets/Music/Busy Day At The Market-LOOP.wav"))
				$"Music Player".set_volume_db(-30)
				$"Music Player".play()
				$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level4Victory2.json"
			else:
				$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level4Victory1.json"
		5:
			Global.unlockedLevels[5] = true
			Global.save_game()
		6:
			Global.unlockedLevels[6] = true
			Global.save_game()
	$CanvasLayer/DialogBox.start_dialog()
	$GameBoard/Cursor.deactivate(true)
	yield($CanvasLayer/DialogBox, "dialog_finished")
	get_tree().change_scene("res://Scenes/Select.tscn")

func defeat() -> void:
	print("Defeat")
	$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level0Defeat.json"
	$"CanvasLayer/update-ui".visible = false
	$CanvasLayer/CommanderUI.visible = false
	match level_number:
		0:
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level0Defeat.json"
		1:
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level1Defeat.json"
		2:
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level2Defeat.json"
		3:
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level3Defeat.json"
		4:
			$CanvasLayer/DialogBox.dialogPath = "res://Dialog/Level4Defeat.json"
		5:
			pass
		6:
			pass
	$CanvasLayer/DialogBox.start_dialog()
	$GameBoard/Cursor.deactivate(true)
	yield($CanvasLayer/DialogBox, "dialog_finished")
	get_tree().change_scene("res://Scenes/Select.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
