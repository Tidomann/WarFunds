extends Node2D

# Member Variables
# Variables that represent the map boundaries
export var fog_map := false
export(int) var xMin
export(int) var xMax
export(int) var yMin
export(int) var yMax
export var gamegrid: Resource
onready var _unit_overlay: UnitOverlay = $GameBoard/UnitOverlay

# Called when the node enters the scene tree for the first time.
func _ready():
	gamegrid.initialize(self)
	$TurnQueue.initialize(self)
	setup_tiles()
	setup_cursor()
	for child in $GameBoard.get_children():
		var unit := child as Unit
		if not unit:
			continue
		unit.update_position()
		if unit.army_sprite:
			unit._sprite.frame = unit.playerOwner.player_colour + ((unit.playerOwner.commander.army_type)*6)
		else:
			unit._sprite.frame = unit.playerOwner.player_colour
	for child in $TurnQueue.get_children():
		$CanvasLayer/CommanderUI.add_player(child)
	for child in $TurnQueue.get_children():
		$CanvasLayer/CommanderUI.income_changed(child, gamegrid.calculate_income(child))
	

	$DialogBox.dialogPath = "res://Dialog/Dialog1.json"
	#$DialogBox.start_dialog()


# Uses the Devtiles tilemap to create the appropriate map on the RenderedTiles
# tilemap
func setup_tiles():
	var tileArray = $Devtiles.get_used_cells()
	for cell in tileArray:
		var tileIndex = $RenderedTiles.tile_set.find_tile_by_name(
			$Devtiles.tile_set.tile_get_name($Devtiles.get_cellv(cell)))
		$RenderedTiles.set_cellv(cell, tileIndex)
		if tileIndex == Constants.TILE.SEA || tileIndex == Constants.TILE.ROAD:
			$RenderedTiles.update_bitmask_area(cell)
	var propertyArray = $Devproperty.get_used_cells()
	var players = $TurnQueue.get_children()
	for cell in propertyArray:
		var temptilevalue = $Devproperty.get_cellv(cell)
		var tempplayer = int(temptilevalue / 6.0)
		var property_type = temptilevalue % 6
		if tempplayer == 0:
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
