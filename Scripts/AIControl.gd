extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var infantry_move = AStar2D.new()
var tread_move = AStar2D.new()
var tire_move = AStar2D.new()
var air_move = AStar2D.new()
var ship_move = AStar2D.new()
export var gamegrid: Resource

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init() -> void:
	var devtiles = gamegrid.devtiles
	var index = 0
	for cell in gamegrid.array:
		if cell != null:
			if gamegrid.is_valid_move(Constants.MOVEMENT_TYPE.INFANTRY, gamegrid.array[index].tileType):
				infantry_move.add_point(index, gamegrid.array[index].coordinates, gamegrid.get_movecost(Constants.MOVEMENT_TYPE.INFANTRY, gamegrid.array[index].tileType))
			if gamegrid.is_valid_move(Constants.MOVEMENT_TYPE.TREAD, gamegrid.array[index].tileType):
				tread_move.add_point(index, gamegrid.array[index].coordinates, gamegrid.get_movecost(Constants.MOVEMENT_TYPE.TREAD, gamegrid.array[index].tileType))
			if gamegrid.is_valid_move(Constants.MOVEMENT_TYPE.TIRES, gamegrid.array[index].tileType):
				tread_move.add_point(index, gamegrid.array[index].coordinates, gamegrid.get_movecost(Constants.MOVEMENT_TYPE.TIRES, gamegrid.array[index].tileType))
			# Skipping air and ship as they dont exist in the game yet
		index += 1
	index = 0
	for cell in devtiles.get_used_cells():
		#print(cell)
		for direction in DIRECTIONS:
			pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
