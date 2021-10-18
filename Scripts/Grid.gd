## Represents a grid with its size, the size of each cell in pixels, and some helper functions to
## calculate and convert coordinates.
## It's meant to be shared between game objects that need access to those values.
class_name Grid
extends Resource

## The the grid size
export (int) var size
## The grid's rows and columns.
export (Vector2) var size2d
## The size of a cell in pixels.
export var cell_size := Vector2(16, 16)
## array of GridData objects
var array = [GridData]
## stored referance to the current battlemap
var battlemap : Node2D
var devtiles : TileMap
var gameBoard : YSort
const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

## Prepare the grid and load the data
func initialize(inbattlemap: Node2D)->void:
	load_grid(inbattlemap)
	load_data()

## Setup the grid object with a passed battlemap
func load_grid(inbattlemap: Node2D):
	battlemap = inbattlemap
	devtiles = battlemap.find_node("Devtiles", false, false)
	gameBoard = battlemap.find_node("GameBoard", false, false)
	var row = battlemap.Xmax() - battlemap.Xmin() + 1
	var col = battlemap.Ymax() - battlemap.Ymin() + 1
	size2d = Vector2(row, col)
	size = row * col
	array.resize(size)

## Initialize the grid data from the tilemap
func load_data():
	# TileType Load
	for cell in devtiles.get_used_cells():
		var array_index = as_index(cell)
		array[array_index] = GridData.new()
		array[array_index].setTileType(devtiles.get_cellv(cell))
		array[array_index].setCoordinatesV2(cell)
	# Unit Load
	for child in gameBoard.get_children():
		var unit := child as Unit
		if not unit:
			continue
		var tempIndex = as_index(unit.get_cell())
		if array[tempIndex].getUnit() == null:
			array[tempIndex].setUnit(unit)
	# TODO: Property Load
	# Testing Array Print
	for cell in array:
		if cell.getUnit() != null:
			print(cell.print())

## Half of ``cell_size``
var _half_cell_size = cell_size / 2

## Returns true if the `grid_position` are within the map
func is_gridcoordinate_within_map(grid_coordinate : Vector2) -> bool:
	if (grid_coordinate.x < battlemap.Xmin() || grid_coordinate.x > battlemap.Xmax()
	|| grid_coordinate.y < battlemap.Ymin() || grid_coordinate.y > battlemap.Ymax()):
		return false
	return true

## Returns the position of a cell's center in pixels.
func calculate_map_position(grid_position: Vector2) -> Vector2:
	if(is_gridcoordinate_within_map(grid_position)):
		return grid_position * cell_size + _half_cell_size
	else:
		return Vector2(-1,-1)

## Returns the coordinates of the cell on the grid given a position on the map.
func calculate_grid_coordinates(map_position: Vector2) -> Vector2:
	var temp_grid_coordinates = (map_position / cell_size).floor()
	if is_gridcoordinate_within_map(temp_grid_coordinates):
		return temp_grid_coordinates
	else:
		return Vector2(-1,-1)

## Calculates the array index
func as_index(cell : Vector2) -> int:
	return int((cell.x- battlemap.Xmin()) +(cell.y- battlemap.Ymin())*15)

## Return the array object at the passed index
func get_CellData(index :int) -> GridData:
	return array[index]

## Makes the `grid_position` fit within the grid's bounds.
func clamp(grid_position: Vector2) -> Vector2:
	var out := grid_position
	out.x = clamp(out.x, 0, size2d.x - 1.0)
	out.y = clamp(out.y, 0, size2d.y - 1.0)
	return out

## Returns true if the grid_position is occupied by another unit
func is_occupied(cell: Vector2) -> bool:
	return true if array[as_index(cell)].getUnit() != null else false

## Find what tiles a unit can move to
func get_walkable_cells(unit: Unit) -> Array:
	return _flood_fill(unit.cell, unit.move_range, unit.movement_type)

# Returns an array with all the coordinates of walkable cells
# based on the `max_distance` and unit movement type
func _flood_fill(cell: Vector2, max_distance: int, movement_type: int) -> Array:
	# The way we implemented the flood fill here is by using a queue. In that queue, we store every
	# cell we want to apply the flood fill algorithm to.
	var queue = [MovementNode]
	queue[0] = MovementNode.new()
	queue[0].setNode(cell, max_distance)
	# Our array of discovered tiles must also hold distance to find the most
	# efficient path. Use the same movement node for this purpose
	var discovered_array = []
	# We loop over cells in the queue, popping one cell on every loop iteration.
	while not queue.empty():
		var skip = false
		var current = queue.pop_front()
		# For each cell, we ensure that we can fill further.
		#
		# The conditions are:
		# 1. We didn't go past the maps's limits.
		# 2. We haven't already visited and filled this cell
		# 3. We are within the `max_distance`, a number of cells.
		#
		# 1. We didn't go past the maps's limits.
		if not is_gridcoordinate_within_map(current.get_cell()):
			continue
		# 2. We haven't already visited and filled this cell
		# if current already discovered AND less effecient, skip
		if not discovered_array.empty():
			for item in discovered_array:
				if skip == false:
					# if the discovered_array has that position
					if item.has(current.get_cell()):
						# chevk if the previous discovery was more effecient
						# otherwise we skip
						# (more movement remaining = more effecient)
						if item.get_movement() >= current.get_movement() :
							skip = true
							# Previous discovery is more effecient, no need to
							# keep iterating
							break
			# outside for iterator of discovered_array
			if skip:
				continue
		# 3. We are within the `max_distance`, a number of cells.
		# This is where we check for the distance between the starting `cell` and the `current` one.
		# A unit should never be able to travel more than it's movement range
		var differance: Vector2 = (current.get_cell() - cell).abs()
		var distance := int(differance.x+differance.y)
		if distance > max_distance:
			continue
		# If we meet all the conditions, we "fill" the `current` cell. To be more accurate, we store
		# it in our discovered_array, to later use them with the UnitPath and UnitOverlay classes.
		discovered_array.append(current)
		# We then look at the `current` cell's neighbors and, if they're not outside the 
		# map or occupied, we add them to the queue for the next iteration.
		# We must attempt tiles we previously discovered to check for the most effecient route
		# This mechanism keeps the loop running until we found all cells the unit can walk.
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current.get_cell() + direction
			# Skip if Neighbour is outside of the map
			if not is_gridcoordinate_within_map(coordinates):
				continue
			# Skip if Neighbour is occupied
			# TODO: Add ally (same player or team) check, can pass through allies
			if is_occupied(coordinates):
				continue
			#if (is_occupied(coordinates) && 
			#get_CellData(as_index(cell)).getUnit().getPlayerOwner()
			#!= get_CellData(as_index(coordinates)).getUnit().getPlayerOwner()):
			#	continue
			# Skip if Neighbour is outside the allowed movement
			var tileType = get_CellData(as_index(coordinates)).getTileType()
			var movecost
			match movement_type:
				Constants.MOVEMENT_TYPE.INFANTRY:
					match tileType:
						Constants.TILE.PLAINS:
							movecost = Constants.INFANTRY_MOVEMENT.PLAINS
						Constants.TILE.FOREST:
							movecost = Constants.INFANTRY_MOVEMENT.FOREST
						Constants.TILE.MOUNTAIN:
							movecost = Constants.INFANTRY_MOVEMENT.MOUNTAIN
						Constants.TILE.SEA:
							skip = true
						Constants.TILE.ROAD:
							movecost = Constants.INFANTRY_MOVEMENT.ROAD
						Constants.TILE.RIVER:
							movecost = Constants.INFANTRY_MOVEMENT.RIVER
						Constants.TILE.SHOAL:
							movecost = Constants.INFANTRY_MOVEMENT.SHOAL
						Constants.TILE.REEF:
							skip = true
				Constants.MOVEMENT_TYPE.MECH:
					continue
				Constants.MOVEMENT_TYPE.TIRES:
					continue
				Constants.MOVEMENT_TYPE.TREAD:
					continue
				Constants.MOVEMENT_TYPE.AIR:
					continue
				Constants.MOVEMENT_TYPE.SHIP:
					continue
				Constants.MOVEMENT_TYPE.TRANS:
					continue
			if skip:
				continue
			if current.get_movement() - movecost < 0:
				continue
			# This is where we extend the stack.
			var temp = MovementNode.new()
			temp.setNode(coordinates, current.get_movement() - movecost)
			queue.push_back(temp)
	# prepare and initialize the flood_array for return
	var flood_array := []
	if not discovered_array.empty():
		for item in discovered_array:
			flood_array.append(item.get_cell())
	return flood_array
