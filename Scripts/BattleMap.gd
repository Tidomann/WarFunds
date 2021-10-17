extends Node2D

# Member Variables
# Variables that represent the map boundaries
export(int) var xMin
export(int) var xMax
export(int) var yMin
export(int) var yMax
export var grid_data: Resource
# Called when the node enters the scene tree for the first time.
func _ready():
	setup_tiles()
	setup_cursor()
	grid_data.start(self)
	

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
	$YSort/Cursor.init($Devtiles)
		

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
