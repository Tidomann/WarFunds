extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# this is a useless comment

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_tiles()
	

func setup_tiles():
	var tileArray = $Devtiles.get_used_cells()
	for cell in tileArray:
		var tileIndex = $RenderedTiles.tile_set.find_tile_by_name(
			$Devtiles.tile_set.tile_get_name($Devtiles.get_cellv(cell)))
		$RenderedTiles.set_cellv(cell, tileIndex)
		if tileIndex == Constants.TILE.SEA || tileIndex == Constants.TILE.ROAD || tileIndex == Constants.TILE.SHOAL:
			$RenderedTiles.update_bitmask_area(cell)
			
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
