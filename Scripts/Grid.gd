## Represents a grid with its size, the size of each cell in pixels, and some helper functions to
## calculate and convert coordinates.
## It's meant to be shared between game objects that need access to those values.
class_name Grid
extends Resource

## The the grid size
export (int) var size
## The grid's rows and columns stored as a Vector2
export (Vector2) var size2d
## The size of a cell in pixels.
export var cell_size := Vector2(16, 16)
## array of GridData objects
var array = [GridData]
## stored referances to the current battlemap
var battlemap : Node2D
var devtiles : TileMap
var gameBoard : YSort

## Half of ``cell_size``
var _half_cell_size = cell_size / 2
const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

## Called when the node enters the scene tree for the first time.
func _ready():
	pass

## Prepare the grid and load the data
func initialize(inbattlemap: Node2D)->void:
	load_grid(inbattlemap)
	load_data()

## Setup the grid object with a passed battlemap
func load_grid(inbattlemap: Node2D):
	# Setup variable referances
	battlemap = inbattlemap
	devtiles = battlemap.find_node("Devtiles", false, false)
	gameBoard = battlemap.find_node("GameBoard", false, false)
	# Calculate space needed for the array
	var row = battlemap.Xmax() - battlemap.Xmin() + 1
	var col = battlemap.Ymax() - battlemap.Ymin() + 1
	size2d = Vector2(row, col)
	size = row * col
	array.resize(size)

## Initialize the grid data from the tilemap
func load_data():
	# TileType Load
	for cell in devtiles.get_used_cells():
		# All used cells in DevTiles should be inside the map boundaries
		# or may overwrite game logic of other tiles
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

## Returns true if the `grid_position` are within the map
func is_gridcoordinate_within_map(grid_coordinate : Vector2) -> bool:
	if (grid_coordinate.x < battlemap.Xmin() || grid_coordinate.x > battlemap.Xmax()
	|| grid_coordinate.y < battlemap.Ymin() || grid_coordinate.y > battlemap.Ymax()):
		return false
	return true

## Returns true if the grid_position contains game data
## Returns false if the grid_position is within map
## but is a blank square
func has_game_data(cell : Vector2) -> bool:
		return array[as_index(cell)] != null

## Take a grid coordinate and find the appropriate position on the screen
## Returns the position of the cell's center in pixels.
func calculate_map_position(grid_position: Vector2) -> Vector2:
	if(is_gridcoordinate_within_map(grid_position)):
		return grid_position * cell_size + _half_cell_size
	else:
		# Object will load back near 0,0
		return Vector2(-1,-1)

## Takes a position on the screen and
## returns the coordinates on the grid
func calculate_grid_coordinates(map_position: Vector2) -> Vector2:
	var temp_grid_coordinates = (map_position / cell_size).floor()
	if is_gridcoordinate_within_map(temp_grid_coordinates):
		return temp_grid_coordinates
	else:
		return Vector2(-1,-1)

## Takes in grid coordinates and returns the appropriate
## index in the griddata array
func as_index(cell : Vector2) -> int:
	return int((cell.x- battlemap.Xmin()) +(cell.y- battlemap.Ymin())*15)

## Return the griddata object at the passed index
func get_GridData(index :int) -> GridData:
	return array[index]

## Return the griddata object at the grid position
func get_GridData_by_position(cell : Vector2) -> GridData:
	return array[as_index(cell)]

## Return the unit at the passed grid position
func get_unit(cell: Vector2) -> Unit:
	if is_occupied(cell):
		return array[as_index(cell)].getUnit()
	return null

## Returns the griddata containing the specified unit
func find_unit(unit: Unit) -> GridData:
	for data in array:
		if data != null:
			if unit == data.getUnit():
				return data
	return null

## Returns the gridposition of the specified unit
func get_unit_position(unit: Unit) -> Vector2:
	for cell in array:
		if cell != null:
			if unit == cell.getUnit():
				return cell.getCoordinates()
	return Vector2.ZERO

## Returns true if the grid_position is occupied by another unit
func is_occupied(cell: Vector2) -> bool:
	return true if array[as_index(cell)].getUnit() != null else false

## Test to see if the two units are enemies
## Returns true if the players of the two units are on seperate teams
func is_enemy(unit: Unit, compareUnit: Unit) -> bool:
	return unit.getPlayerOwner().team != compareUnit.getPlayerOwner().team

## Find what tiles a unit can move to
func get_walkable_cells(unit: Unit) -> Array:
	return _flood_fill(unit.cell, unit.move_range, unit.movement_type)

## Find what tiles a unit can attack
func get_attackable_cells(unit: Unit) -> Array:
	var attack_array := []
	match unit.attack_type:
		Constants.ATTACK_TYPE.DIRECT:
			var compare_array = _flood_fill(unit.cell, unit.move_range+1, unit.movement_type)
			attack_array = compare_array.duplicate()
			for cell in compare_array:
				for direction in DIRECTIONS:
					var coordinates: Vector2 = cell + direction
					if not is_gridcoordinate_within_map(coordinates):
						continue
					if not compare_array.has(coordinates):
						if not attack_array.has(coordinates):
							attack_array.append(coordinates)
		Constants.ATTACK_TYPE.INDIRECT:
			attack_array = _flood_fill(unit.cell, unit.atk_range, Constants.MOVEMENT_TYPE.AIR, true)
			var min_range_array = _flood_fill(unit.cell, unit.min_atk_range, Constants.MOVEMENT_TYPE.AIR, true)
			for cell in min_range_array:
				attack_array.erase(cell)
		Constants.ATTACK_TYPE.OTHER:
			var compare_array = _flood_fill(unit.cell, unit.move_range+unit.atk_range, unit.movement_type)
			attack_array = compare_array.duplicate()
			for cell in compare_array:
				for direction in DIRECTIONS:
					var coordinates: Vector2 = cell
					for n in unit.atk_range:
						coordinates += direction
						if not is_gridcoordinate_within_map(coordinates):
							continue
						if not compare_array.has(coordinates):
							if not attack_array.has(coordinates):
								attack_array.append(coordinates)
	return attack_array

## Returns an array with all the coordinates of walkable cells
## based on the `max_distance` and unit movement type
## attackcheck ignores collision with ALL units
func _flood_fill(cell: Vector2, max_distance: int, movement_type: int,
				attackcheck: bool = false) -> Array:
	# The way we implemented the flood fill here is by using a queue.
	# In that queue, we store every cell we want to apply the flood fill algorithm to.
	# In order to iterate through all possbilities without using recursive calls
	var queue = [MovementNode]
	# movement nodes stores a location and an int representing move remaining
	queue[0] = MovementNode.new()
	# Store the starting position as the first cell to check
	queue[0].setNode(cell, max_distance)
	# Store the results in an array so we can compare efficiencies
	var discovered_array = []
	# Loop over cells in the queue, popping one cell on every loop iteration.
	while not queue.empty():
		var skip = false #control flow variable
		var current = queue.pop_front()
		# For each cell, we ensure that we can fill further.
		#
		# The conditions are:
		# 1. We didn't go past the maps's limits.
		# 2. The cell we visit is a more effecient path
		# 3. We are within the `max_distance`
		#
		# 1. We didn't go past the maps's limits.
		if not is_gridcoordinate_within_map(current.cell):
			continue
		# 2. The cell we visit is a more effecient path
		if not discovered_array.empty():
			for item in discovered_array:
				if skip == false:
					# If we have already visited this tile
					if item.has(current.get_cell()):
						# Check if new path is more effecient
						# (more movement remaining = more effecient)
						if item.get_movement() >= current.get_movement() :
							# Previous discovery is more effecient
							skip = true
							break
			# If we are on a less effecient path, stop checking
			if skip:
				continue
		# 3. We are within the `max_distance`
		# Check for the distance between starting `cell` and `current`
		# A unit should never be able to travel more than it's movement range
		var differance: Vector2 = (current.get_cell() - cell).abs()
		var distance := int(differance.x+differance.y)
		if distance > max_distance:
			continue
		# All conditions are met, store the cell as visited
		discovered_array.append(current)
		# Look at the `current` cell's neighbors, if they're not outside the 
		# map or occupied, add to the queue for the next iteration. Must add 
		# tiles even if we previously discovered to check 
		# for the most effecient route
		# This mechanism keeps the loop running until we found all cells
		# the unit can walk.
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current.get_cell() + direction
			# Skip if Neighbour is outside of the map
			if not is_gridcoordinate_within_map(coordinates):
				continue
			# Parameter specifies if we should test unit collision
			if not attackcheck:
				# If map has fog, we need to allow units to become trapped
				if not battlemap.fog_map:
					if not has_game_data(coordinates):
						continue
					if is_occupied(coordinates):
						if is_enemy(get_unit(cell), get_unit(coordinates)):
							continue
				else:
					# TODO: Once vision is implemented revisit
					# fill as normal if the tile is revealed
					# otherwise we need to skip unit collisions
					# can probably implement by changing previous logic
					# change !fog_map to tile_revealed logic
					pass
			# Tests to see if unit can move to neighbour
			var movecost
			var tileType
			if not attackcheck:
				# Tile within map is blank
				if not has_game_data(coordinates):
					continue
				tileType = get_GridData_by_position(coordinates).getTileType()
				# Skip if the unit can't move to the tile
				if not is_valid_move(movement_type, tileType):
					continue
				# Check to see if the unit has exhausted all it's move range
				movecost = get_movecost(movement_type, tileType)
			else:
				movecost = 1
			# Skip If we don't have enough movement remaining
			if current.get_movement() - movecost < 0:
				continue
			# This is where we extend the stack.
			var temp = MovementNode.new()
			temp.setNode(coordinates, current.get_movement() - movecost)
			queue.push_back(temp)
	# Prepare and initialize the flood_array for return
	var flood_array := []
	if not discovered_array.empty():
		for item in discovered_array:
			# Finding range may include cells without data
			if has_game_data(item.cell):
				flood_array.append(item.get_cell())
	return flood_array

func is_valid_move(movement_type: int, tiletype: int) -> bool:
	match movement_type:
		Constants.MOVEMENT_TYPE.INFANTRY:
			match tiletype:
				Constants.TILE.SEA:
					return false
				Constants.TILE.REEF:
					return false
		Constants.MOVEMENT_TYPE.MECH:
			match tiletype:
				Constants.TILE.SEA:
					return false
				Constants.TILE.REEF:
					return false
		Constants.MOVEMENT_TYPE.TIRES:
			match tiletype:
				Constants.TILE.MOUNTAIN:
					return false
				Constants.TILE.SEA:
					return false
				Constants.TILE.RIVER:
					return false
				Constants.TILE.REEF:
					return false
		Constants.MOVEMENT_TYPE.TREAD:
			match tiletype:
				Constants.TILE.MOUNTAIN:
					return false
				Constants.TILE.SEA:
					return false
				Constants.TILE.RIVER:
					return false
				Constants.TILE.REEF:
					return false
		Constants.MOVEMENT_TYPE.SHIP:
			continue
		Constants.MOVEMENT_TYPE.TRANS:
			continue
	return true

func get_movecost(movement_type: int, tiletype: int) -> int:
	match movement_type:
		Constants.MOVEMENT_TYPE.INFANTRY:
			match tiletype:
				Constants.TILE.PLAINS:
					return Constants.INFANTRY_MOVEMENT.PLAINS
				Constants.TILE.FOREST:
					return Constants.INFANTRY_MOVEMENT.FOREST
				Constants.TILE.MOUNTAIN:
					return Constants.INFANTRY_MOVEMENT.MOUNTAIN
				Constants.TILE.SEA:
					return 9999
				Constants.TILE.ROAD:
					return Constants.INFANTRY_MOVEMENT.ROAD
				Constants.TILE.RIVER:
					return Constants.INFANTRY_MOVEMENT.RIVER
				Constants.TILE.SHOAL:
					return Constants.INFANTRY_MOVEMENT.SHOAL
				Constants.TILE.REEF:
					return 9999
		Constants.MOVEMENT_TYPE.MECH:
			match tiletype:
				Constants.TILE.PLAINS:
					return Constants.MECH_MOVEMENT.PLAINS
				Constants.TILE.FOREST:
					return Constants.MECH_MOVEMENT.FOREST
				Constants.TILE.MOUNTAIN:
					return Constants.MECH_MOVEMENT.MOUNTAIN
				Constants.TILE.SEA:
					return 9999
				Constants.TILE.ROAD:
					return Constants.MECH_MOVEMENT.ROAD
				Constants.TILE.RIVER:
					return Constants.MECH_MOVEMENT.RIVER
				Constants.TILE.SHOAL:
					return Constants.MECH_MOVEMENT.SHOAL
				Constants.TILE.REEF:
					return 9999
		Constants.MOVEMENT_TYPE.TIRES:
			match tiletype:
				Constants.TILE.PLAINS:
					return Constants.TIRE_MOVEMENT.PLAINS
				Constants.TILE.FOREST:
					return Constants.TIRE_MOVEMENT.FOREST
				Constants.TILE.MOUNTAIN:
					return 9999
				Constants.TILE.SEA:
					return 9999
				Constants.TILE.ROAD:
					return Constants.TIRE_MOVEMENT.ROAD
				Constants.TILE.RIVER:
					return 9999
				Constants.TILE.SHOAL:
					return Constants.TIRE_MOVEMENT.SHOAL
				Constants.TILE.REEF:
					return 9999
		Constants.MOVEMENT_TYPE.TREAD:
			match tiletype:
				Constants.TILE.PLAINS:
					return Constants.TREAD_MOVEMENT.PLAINS
				Constants.TILE.FOREST:
					return Constants.TREAD_MOVEMENT.FOREST
				Constants.TILE.MOUNTAIN:
					return 9999
				Constants.TILE.SEA:
					return 9999
				Constants.TILE.ROAD:
					return Constants.TREAD_MOVEMENT.ROAD
				Constants.TILE.RIVER:
					return 9999
				Constants.TILE.SHOAL:
					return Constants.TREAD_MOVEMENT.SHOAL
				Constants.TILE.REEF:
					return 9999
		Constants.MOVEMENT_TYPE.AIR:
			return 1
		Constants.MOVEMENT_TYPE.SHIP:
			return 9999
		Constants.MOVEMENT_TYPE.TRANS:
			return 9999
	return 9999

func enemy_in_range(unit: Unit, start_position: Vector2, end_position: Vector2) -> bool:
	match unit.attack_type:
		Constants.ATTACK_TYPE.DIRECT:
			for direction in DIRECTIONS:
				var coordinates: Vector2 = start_position + direction
				if is_occupied(coordinates):
					if is_enemy(unit, get_unit(coordinates)):
						return true
		Constants.ATTACK_TYPE.INDIRECT:
			if start_position != end_position:
				return false
			var attackable_cells = get_attackable_cells(unit)
			for cell in attackable_cells:
				if is_occupied(cell):
					if is_enemy(unit, get_unit(cell)):
						return true
		Constants.ATTACK_TYPE.OTHER:
			pass
	return false

func get_players_units(player : Node2D):
	var units = []
	for cell in array:
		if cell.has_Unit():
			var tempunit = cell.getUnit()
			if tempunit.playerOwner == player:
				units.append(tempunit)
	return units

## Makes the `grid_position` fit within the grid's bounds.
## Most likely obselete code
func clamp(grid_position: Vector2) -> Vector2:
	var out := grid_position
	out.x = clamp(out.x, 0, size2d.x - 1.0)
	out.y = clamp(out.y, 0, size2d.y - 1.0)
	return out
