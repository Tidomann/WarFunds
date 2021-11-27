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
var propertytiles : TileMap

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
	propertytiles = battlemap.find_node("Devproperty", false, false)
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
	for child in gameBoard.get_node("Units").get_children():
		var unit := child as Unit
		if not unit:
			continue
		var tempIndex = as_index(unit.get_cell())
		if array[tempIndex].getUnit() == null:
			array[tempIndex].setUnit(unit)
	var players = gameBoard._turn_queue.get_children()
	# TODO: Property Load
	for cell in propertytiles.get_used_cells():
		var array_index = as_index(cell)
		var temptilevalue = propertytiles.get_cellv(cell)
		var tempplayer = int(temptilevalue / 6.0)
		if tempplayer == 0:
			tempplayer = null
		else:
			tempplayer -= 1
		var property_type = temptilevalue % 6
		var griddata_referance = array[array_index] 
		griddata_referance.property = load("res://Scripts/Property.gd").new()
		griddata_referance.property.cell = cell
		griddata_referance.property.property_referance = property_type
		if tempplayer != null && tempplayer < players.size():
			griddata_referance.property.playerOwner = players[tempplayer]
		else:
			griddata_referance.property.playerOwner = null

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
	# must return false to avoid attempting to check enemies at location
	if array[as_index(cell)] == null:
		return false
	return true if array[as_index(cell)].getUnit() != null else false

## Test to see if the two units are enemies
## Returns true if the players of the two units are on seperate teams
func is_enemy(unit: Unit, compareUnit: Unit) -> bool:
	return unit.getPlayerOwner().team != compareUnit.getPlayerOwner().team

## Find what tiles a unit can move to
func get_walkable_cells(unit: Unit) -> Array:
	return _flood_fill(unit.cell, unit.get_move_range(), unit.movement_type)

## Find what tiles a unit can attack
func get_attackable_cells(unit: Unit) -> Array:
	var attack_array := []
	match unit.attack_type:
		Constants.ATTACK_TYPE.DIRECT:
			var compare_array = _flood_fill(unit.cell, unit.get_move_range(), unit.movement_type)
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
			var compare_array = _flood_fill(unit.cell, unit.get_move_range(), unit.movement_type)
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
				if not is_valid_move(movement_type, tileType) && not has_property(coordinates):
					continue
				# Check to see if the unit has exhausted all it's move range
				# Code may need to be adjusting when adding ship units
				# Ships won't move through bases or airports?
				if has_property(coordinates):
					movecost = 1
				else:
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
				var coordinates: Vector2 = end_position + direction
				if is_gridcoordinate_within_map(coordinates):
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
			unit.attack_type = Constants.ATTACK_TYPE.INDIRECT
			var attackable_cells = get_attackable_cells(unit)
			for cell in attackable_cells:
				if is_occupied(cell):
					if is_enemy(unit, get_unit(cell)):
						unit.attack_type = Constants.ATTACK_TYPE.OTHER
						return true
			unit.attack_type = Constants.ATTACK_TYPE.OTHER
	return false

func get_players_units(player : Node2D):
	var units = []
	for data in array:
		if data != null:
			if data.has_Unit():
				var tempunit = data.getUnit()
				if tempunit.playerOwner == player:
					units.append(tempunit)
	return units

func get_targets(attacker: Unit, expected_position : Vector2) -> Array:
	var targets_array = []
	match attacker.attack_type:
		Constants.ATTACK_TYPE.DIRECT:
			for direction in DIRECTIONS:
				var coordinates: Vector2 = expected_position + direction
				if is_gridcoordinate_within_map(coordinates):
					if is_occupied(coordinates):
						if is_enemy(attacker, get_unit(coordinates)):
							targets_array.append(get_unit(coordinates))
		Constants.ATTACK_TYPE.INDIRECT:
			if attacker.cell != expected_position:
				return targets_array
			var attackable_cells = get_attackable_cells(attacker)
			for cell in attackable_cells:
				if is_occupied(cell):
					if is_enemy(attacker, get_unit(cell)):
						targets_array.append(get_unit(cell))
		Constants.ATTACK_TYPE.OTHER:
			attacker.attack_type = Constants.ATTACK_TYPE.INDIRECT
			var position_store = attacker.cell
			attacker.cell = expected_position
			var attackable_cells = get_attackable_cells(attacker)
			for cell in attackable_cells:
				if is_occupied(cell):
					if is_enemy(attacker, get_unit(cell)):
						targets_array.append(get_unit(cell))
			attacker.attack_type = Constants.ATTACK_TYPE.OTHER
			attacker.cell = position_store
	return targets_array

func calculate_min_damage(attacker : Unit, defender : Unit, damagedealt=0) -> int:
	if attacker.unit_referance == Constants.UNIT.TOWER:
		return 30
	var damage_lookup = Constants.get_damage(attacker.unit_referance, defender.unit_referance)
	var commander_attack_bonus = attacker.get_commander().strength_modifier(attacker, defender)
	var commander_defense_bonus = defender.get_commander().defense_modifier(attacker, defender)
	var bad_luck = attacker.get_commander().bad_luck_modifier()
	#var terrain_bonus = Constants.TILE_DEFENSE[get_GridData_by_position(defender.cell).getTileType()]
	var terrain_bonus = get_terrain_bonus(get_GridData_by_position(defender.cell))
	var full_damage = (damage_lookup * commander_attack_bonus / 100.0) + bad_luck
	var health_modifier = (ceil((attacker.health-damagedealt)/10.0) / 10.0)
	var reduction_modifier = ((200-(commander_defense_bonus+terrain_bonus*ceil(defender.health/10.0)))/100)
	var result = full_damage * health_modifier * reduction_modifier
	return int(floor(result))

func calculate_max_damage(attacker : Unit, defender : Unit, damagedealt=0) -> int:
	if attacker.unit_referance == Constants.UNIT.TOWER:
		return 30
	var damage_lookup = Constants.get_damage(attacker.unit_referance, defender.unit_referance)
	var commander_attack_bonus = attacker.get_commander().strength_modifier(attacker, defender)
	var commander_defense_bonus = defender.get_commander().defense_modifier(attacker, defender)
	var good_luck = attacker.get_commander().luck_modifier()
	#var terrain_bonus = Constants.TILE_DEFENSE[get_GridData_by_position(defender.cell).getTileType()]
	var terrain_bonus = get_terrain_bonus(get_GridData_by_position(defender.cell))
	var full_damage = (damage_lookup * commander_attack_bonus / 100.0) + good_luck
	var health_modifier = (ceil((attacker.health-damagedealt)/10.0) / 10.0)
	var reduction_modifier = ((200-(commander_defense_bonus+terrain_bonus*ceil(defender.health/10.0)))/100)
	var result = full_damage * health_modifier * reduction_modifier
	return int(floor(result))


#This is where real damage happens
func calculate_damage(attacker : Unit, defender : Unit) -> int:
	attacker.get_commander().special_attack(attacker, defender)
	if attacker.unit_referance == Constants.UNIT.TOWER:
		return 30
	var damage_lookup = Constants.get_damage(attacker.unit_referance, defender.unit_referance)
	var commander_attack_bonus = attacker.get_commander().strength_modifier(attacker, defender)
	var commander_defense_bonus = defender.get_commander().defense_modifier(attacker, defender)
	var bad_luck = attacker.get_commander().bad_luck_modifier()
	var good_luck = attacker.get_commander().luck_modifier()
	var luck_modifier = bad_luck + randi()%(good_luck - bad_luck +1)
	#var terrain_bonus = Constants.TILE_DEFENSE[get_GridData_by_position(defender.cell).getTileType()]
	var terrain_bonus = get_terrain_bonus(get_GridData_by_position(defender.cell))
	var full_damage = (damage_lookup * commander_attack_bonus / 100.0) + luck_modifier
	var health_modifier = (ceil(attacker.health/10.0) / 10.0)
	var reduction_modifier = ((200-(commander_defense_bonus+terrain_bonus*ceil(defender.health/10.0)))/100)
	var result = full_damage * health_modifier * reduction_modifier
	#print("Real result: " + String(floor(result)))
	return int(floor(result))

func unit_combat(attacker : Unit, defender : Unit):
	var damage_to_be_dealt = calculate_damage(attacker, defender)
	var defender_damage_taken = 0
	var attacker_damage_taken = 0
	# If both units are not direct, can skip retaliation attack
	if not attacker.attack_type == Constants.ATTACK_TYPE.DIRECT\
	|| not defender.attack_type == Constants.ATTACK_TYPE.DIRECT:
		defender_damage_taken = defender.take_damage(damage_to_be_dealt)
	# Direct combat units, will take retaliation damage
	else:
		if (damage_to_be_dealt >= defender.health):
			defender_damage_taken = defender.take_damage(damage_to_be_dealt)
		else:
			defender_damage_taken = defender.take_damage(damage_to_be_dealt)
			attacker_damage_taken = attacker.take_damage(calculate_damage(defender, attacker))
	# attacker gets 50% of the damage dealt in power
	# defender gets 100% of the damage recieved in power
	# Calculate the cost of funds dealth/lost in terms of the unit health displayed
	# IE the unit losses 5 displayed life, 50% of the cost given to defender 50% of the 50% to attacker
	attacker.get_commander().addPower((int(defender_damage_taken)*defender.cost*0.1)*0.5)
	defender.get_commander().addPower(int(defender_damage_taken)*defender.cost*0.1)
	if attacker_damage_taken > 0:
		defender.get_commander().addPower((int(attacker_damage_taken)*attacker.cost*0.1)*0.5)
		attacker.get_commander().addPower(int(attacker_damage_taken)*attacker.cost*0.1)
	if attacker.is_dead():
		find_unit(attacker).unit = null
		attacker.queue_free()
	if defender.is_dead():
		find_unit(defender).unit = null
		defender.queue_free()

func get_terrain_bonus(grid_data : GridData) -> int:
	if grid_data.property !=null:
		if grid_data.property.property_referance == Constants.PROPERTY.HQ:
			return 4
		return 3
	else:
		return Constants.TILE_DEFENSE[grid_data.getTileType()]

func calculate_income(player : Node2D) -> int:
	var income = 0
	for cell in propertytiles.get_used_cells():
		var array_index = as_index(cell)
		if array[array_index].property.playerOwner == player:
			income += 1000
	return income

func start_turn_income(player : Node2D) -> int:
	var income = 0
	for cell in propertytiles.get_used_cells():
		var game_data = array[as_index(cell)]
		# If the player owns a property
		if game_data.property.playerOwner == player:
			income += 1000
			# If the property is a tower increase their power as well
			if game_data.property.property_referance == Constants.PROPERTY.TOWER:
				game_data.property.playerOwner.addPower(800)
			# If the property has a unit on it repair the unit
			# START TURN PROPERTY HEAL
			if game_data.has_Unit():
				if game_data.unit.playerOwner == player:
					if game_data.unit.heal_differance(20)*0.1*game_data.unit.cost < player.funds:
						var heal_cost = game_data.unit.get_healing(20)
						player.addFunds(-heal_cost)
	return income

func has_property(cell : Vector2) -> bool:
	if array[as_index(cell)].property != null:
		return true
	return false

func can_capture(cell: Vector2, unit : Unit) -> bool:
	if not has_property(cell):
		return false
	else:
		if unit.unit_type == Constants.UNIT_TYPE.INFANTRY:
			if array[as_index(cell)].property.playerOwner == null:
				return true
			elif array[as_index(cell)].property.playerOwner.team != unit.playerOwner.team:
				return true
		return false

func get_properties() -> Array:
	var property_array := []
	for cell in propertytiles.get_used_cells():
		property_array.append(array[as_index(cell)].property)
	return property_array

func get_property(cell: Vector2) -> PropertyWF:
	if not has_property(cell):
		return null
	else:
		return array[as_index(cell)].property

## Makes the `grid_position` fit within the grid's bounds.
## Most likely obselete code
func clamp(grid_position: Vector2) -> Vector2:
	var out := grid_position
	out.x = clamp(out.x, 0, size2d.x - 1.0)
	out.y = clamp(out.y, 0, size2d.y - 1.0)
	return out
