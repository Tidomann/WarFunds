
# Draws an overlay over an array of cells.
class_name UnitOverlay
extends TileMap

# By making the tilemap half-transparent, using the modulate property, we only have two draw the
# cells, and we automatically get a nice overlay on the board.
# The function fills the tilemap with the cells, giving visual feedback on where a unit can walk.
func draw(cells: Array) -> void:
	clear()
	$OverlayFill.clear()
	# We loop over the cells and assign them the only tile available in the tileset, tile 0.
	for cell in cells:
		$OverlayFill.set_cellv(cell, 1)
		self.set_cellv(cell, 0)
	
	update_bitmask_region()

func draw_red(cells: Array) -> void:
	clear()
	$OverlayFill.clear()
	# We loop over the cells and assign them the only tile available in the tileset, tile 0.
	for cell in cells:
		$OverlayFill.set_cellv(cell, 3)
		self.set_cellv(cell, 2)
	
	update_bitmask_region()

func totalclear() -> void:
	clear()
	$OverlayFill.clear()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
