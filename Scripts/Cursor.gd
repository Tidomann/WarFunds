extends Sprite

var oldcoords
var coordinates
var mousePosition
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func update():
	self.position = get_global_mouse_position().snapped(Vector2(16,16))
	
func updateOnMap(map:TileMap):
	#Get mouse position, store position and corresponding TileMap coordinate
	mousePosition = get_global_mouse_position()
	coordinates = map.world_to_map(mousePosition)
	#Test to see if TileMap is populated (-1 is empty tile)
	if map.get_cellv(coordinates) != -1:
		#self.position = mousePosition.snapped(Vector2(16,16))
		#Get new position based on tile coordinate
		mousePosition = map.map_to_world(coordinates)
		#adjust position to be center of tile (+ tilesize/2)
		mousePosition.x += 8
		mousePosition.y += 8
		#update mouse position
		self.position = mousePosition
	"""
	#This is to test mouse position output
	if coordinates != oldcoords:
		print(mousePosition)
		print(coordinates)
		oldcoords = coordinates
	"""


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
