extends Node2D

# Member Variables
# Variables that represent the map boundaries
export(int) var xMin
export(int) var xMax
export(int) var yMin
export(int) var yMax
export var gamegrid: Resource
onready var _unit_overlay: UnitOverlay = $GameBoard/UnitOverlay

# Called when the node enters the scene tree for the first time.
func _ready():
	var menu = $PopupMenu.add_item("ddsdsd")
	gamegrid.initialize(self)
	setup_tiles()
	setup_cursor()
	$GameBoard._reinitialize()
	for child in $GameBoard.get_children():
		var unit := child as Unit
		if not unit:
			continue
		unit.update_position()


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
			

# Initializes the cursor using the cursor.init function so the cursor knows
# what tiles exist in the map
func setup_cursor():
	$GameBoard/Cursor.init($Devtiles)
		

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
