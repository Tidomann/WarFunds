extends Node2D


var dijkstra_map: DijkstraMap = DijkstraMap.new()
export var gamegrid: Resource
var battlemap

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(inbattlemap : Node2D) -> void:
	battlemap = inbattlemap
	var devtiles = gamegrid.devtiles
	var index = 0
	for cell in gamegrid.array:
		if cell != null:
			dijkstra_map.add_point(index, cell.tileType)
		index += 1
	index = 0
	for cell in devtiles.get_used_cells():
		for direction in DIRECTIONS:
			var adjacent_coordinate: Vector2 = cell + direction
			if not gamegrid.is_gridcoordinate_within_map(adjacent_coordinate):
				continue
			if devtiles.get_cellv(adjacent_coordinate) != -1 && not dijkstra_map.has_connection(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate)):
				dijkstra_map.connect_points(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate))

func recalculate_map(movement_type : int, cell : Vector2) -> void:
	var cost_dict
	match movement_type:
		Constants.MOVEMENT_TYPE.INFANTRY:
			cost_dict = {Constants.TILE.PLAINS: 1.0, Constants.TILE.FOREST: 1.0, Constants.TILE.MOUNTAIN: 2.0, Constants.TILE.ROAD: 1.0, Constants.TILE.RIVER: 2.0, Constants.TILE.SHOAL: 1.0}
		Constants.MOVEMENT_TYPE.MECH:
			cost_dict = {Constants.TILE.PLAINS: 1.0, Constants.TILE.FOREST: 1.0, Constants.TILE.MOUNTAIN: 1.0, Constants.TILE.ROAD: 1.0, Constants.TILE.RIVER: 1.0, Constants.TILE.SHOAL: 1.0}
		Constants.MOVEMENT_TYPE.TIRES:
			cost_dict = {Constants.TILE.PLAINS: 2.0, Constants.TILE.FOREST: 3.0, Constants.TILE.ROAD: 1.0, Constants.TILE.SHOAL: 1.0}
		Constants.MOVEMENT_TYPE.TREAD:
			cost_dict = {Constants.TILE.PLAINS: 1.0, Constants.TILE.FOREST: 2.0, Constants.TILE.ROAD: 1.0, Constants.TILE.SHOAL: 1.0}
		Constants.MOVEMENT_TYPE.AIR:
			cost_dict = {Constants.TILE.PLAINS: 1.0, Constants.TILE.FOREST: 1.0, Constants.TILE.MOUNTAIN: 1.0, Constants.TILE.SEA: 1.0, Constants.TILE.ROAD: 1.0, Constants.TILE.RIVER: 1.0, Constants.TILE.SHOAL: 1.0, Constants.TILE.REEF: 1.0}
		Constants.MOVEMENT_TYPE.SHIP:
			# not yet implemented
			pass
	var optional_params = {
		"terrain_weights": cost_dict,
	}
	dijkstra_map.recalculate(gamegrid.as_index(cell), optional_params)

func recalculate_to_targets_map(movement_type : int, array : Array) -> void:
	var cost_dict
	match movement_type:
		Constants.MOVEMENT_TYPE.INFANTRY:
			cost_dict = {Constants.TILE.PLAINS: 1.0, Constants.TILE.FOREST: 1.0, Constants.TILE.MOUNTAIN: 2.0, Constants.TILE.ROAD: 1.0, Constants.TILE.RIVER: 2.0, Constants.TILE.SHOAL: 1.0}
		Constants.MOVEMENT_TYPE.MECH:
			cost_dict = {Constants.TILE.PLAINS: 1.0, Constants.TILE.FOREST: 1.0, Constants.TILE.MOUNTAIN: 1.0, Constants.TILE.ROAD: 1.0, Constants.TILE.RIVER: 1.0, Constants.TILE.SHOAL: 1.0}
		Constants.MOVEMENT_TYPE.TIRES:
			cost_dict = {Constants.TILE.PLAINS: 2.0, Constants.TILE.FOREST: 3.0, Constants.TILE.ROAD: 1.0, Constants.TILE.SHOAL: 1.0}
		Constants.MOVEMENT_TYPE.TREAD:
			cost_dict = {Constants.TILE.PLAINS: 1.0, Constants.TILE.FOREST: 2.0, Constants.TILE.ROAD: 1.0, Constants.TILE.SHOAL: 1.0}
		Constants.MOVEMENT_TYPE.AIR:
			cost_dict = {Constants.TILE.PLAINS: 1.0, Constants.TILE.FOREST: 1.0, Constants.TILE.MOUNTAIN: 1.0, Constants.TILE.SEA: 1.0, Constants.TILE.ROAD: 1.0, Constants.TILE.RIVER: 1.0, Constants.TILE.SHOAL: 1.0, Constants.TILE.REEF: 1.0}
		Constants.MOVEMENT_TYPE.SHIP:
			# not yet implemented
			pass
	var optional_params = {
		"input_is_destination": true,
		"terrain_weights": cost_dict
	}
	dijkstra_map.recalculate(array, optional_params)

func best_attack_path_direct(attacker : Unit) -> PoolVector2Array:
	recalculate_map(attacker.movement_type, attacker.cell)
	var dijkstra_tiles = dijkstra_map.get_all_points_with_cost_between(0.0, float(attacker.move_range+1))
	var test_array : Array = []
	for index in dijkstra_tiles:
		test_array.append(gamegrid.array[index].coordinates)
	var target_list : Array = []
	for unit in battlemap._units_node.get_children():
		if test_array.has(unit.cell):
			if unit.playerOwner.team != attacker.playerOwner.team:
				if is_good_attack(attacker, unit):
					target_list.append(unit)
	# can we reach each target in the target_list
	if not target_list.empty():
		var reachable_targets : Array = []
		for unit in battlemap._units_node.get_children():
			# Attacker cannot travel on top of enemy
			if attacker.playerOwner.team != unit.playerOwner.team:
				dijkstra_map.disable_point(gamegrid.as_index(unit.cell))
		recalculate_map(attacker.movement_type, attacker.cell)
		# Check all possible targets
		for target in target_list:
			for direction in DIRECTIONS:
				if not gamegrid.is_gridcoordinate_within_map(target.cell + direction):
					continue
				# Do we have a path next to the targets if we are blocked by enemy units and
				# is the end of that path not occupied already
				if not dijkstra_map.get_shortest_path_from_point(gamegrid.as_index(target.cell + direction)).empty() &&\
				not gamegrid.is_occupied(target.cell + direction):
					if not reachable_targets.has(target):
						reachable_targets.append(target)
		# find the best target of available targets
		if not reachable_targets.empty():
			var max_funds_damage = 0
			var best_target
			for target in reachable_targets:
				var temp_damage = gamegrid.calculate_max_damage(attacker, target)
				var funds_damage = temp_damage * 0.01 * target.cost
				if funds_damage > max_funds_damage:
					# If the unit will retaliate back, only consider it a good target if the damage
					if target.attack_type == Constants.ATTACK_TYPE.DIRECT:
						var funds_damage_recieved = gamegrid.calculate_max_damage(target, attacker, temp_damage) * 0.01 * attacker.cost
						# Dont consider this a good trade
						if funds_damage < funds_damage_recieved * 0.8:
							continue
					max_funds_damage = funds_damage
					best_target = target
			var best_defense = 0
			var destination = null
			for direction in DIRECTIONS:
				if not gamegrid.is_gridcoordinate_within_map(best_target.cell + direction):
					continue
				if not dijkstra_map.get_shortest_path_from_point(gamegrid.as_index(best_target.cell + direction)).empty() &&\
				not gamegrid.is_occupied(best_target.cell + direction):
						if destination == null:
							best_defense = gamegrid.get_terrain_bonus(gamegrid.array[gamegrid.as_index(best_target.cell + direction)])
							destination = best_target.cell + direction
						else:
							if best_defense < gamegrid.get_terrain_bonus(gamegrid.array[gamegrid.as_index(best_target.cell + direction)]):
								best_defense = gamegrid.get_terrain_bonus(gamegrid.array[gamegrid.as_index(best_target.cell + direction)])
								destination = best_target.cell + direction
			var destination_path : PoolVector2Array = []
			var dijkstra_path = dijkstra_map.get_shortest_path_from_point(gamegrid.as_index(destination))
			for n in range(dijkstra_path.size()-1,-1,-1):
				destination_path.append(gamegrid.array[dijkstra_path[n]].coordinates)
			destination_path.append(destination)
			reactivate_all_points()
			battlemap._unit_overlay.draw(destination_path)
			return destination_path
		# no reachable targets within range
		# points are still disabled at this point
		else:
			return no_targets_direct_path(attacker)
			"""var long_distance_coordinates : Array = []
			var destination_path : PoolVector2Array = []
			for unit in battlemap._units_node.get_children():
				if unit.playerOwner.team != attacker.playerOwner.team:
					long_distance_coordinates.append(gamegrid.as_index(unit.cell))
			if not long_distance_coordinates.empty():
				var final_move_blocked = true
				while final_move_blocked:
					destination_path = []
					recalculate_to_targets_map(attacker.movement_type,long_distance_coordinates)
					# Set starting index
					destination_path.append(attacker.cell)
					var next_index = gamegrid.as_index(attacker.cell)
					var move_distance = dijkstra_map.get_cost_at_point(next_index)
					while move_distance - dijkstra_map.get_cost_at_point(next_index) < attacker.move_range:
						next_index = dijkstra_map.get_direction_at_point(next_index)
						destination_path.append(gamegrid.array[next_index].coordinates)
					# if the final destination coordinate is blocked
					if gamegrid.array[next_index].getUnit() != null:
						dijkstra_map.disable_point(next_index)
					else:
						final_move_blocked = false
				reactivate_all_points()
				battlemap._unit_overlay.draw(destination_path)
				return destination_path
			else:
				reactivate_all_points()
				battlemap._unit_overlay.draw(destination_path)
				return destination_path"""
	# no targets within range
	else:
		return no_targets_direct_path(attacker)
		"""var long_distance_coordinates : Array = []
		var destination_path : PoolVector2Array = []
		for unit in battlemap._units_node.get_children():
			if unit.playerOwner.team != attacker.playerOwner.team:
				long_distance_coordinates.append(gamegrid.as_index(unit.cell))
		if not long_distance_coordinates.empty():
			var final_move_blocked = true
			while final_move_blocked:
				destination_path = []
				recalculate_to_targets_map(attacker.movement_type,long_distance_coordinates)
				# Set starting index
				destination_path.append(attacker.cell)
				var next_index = gamegrid.as_index(attacker.cell)
				var move_distance = dijkstra_map.get_cost_at_point(next_index)
				while move_distance - dijkstra_map.get_cost_at_point(next_index) < attacker.move_range:
					next_index = dijkstra_map.get_direction_at_point(next_index)
					destination_path.append(gamegrid.array[next_index].coordinates)
				# if the final destination coordinate is blocked
				if gamegrid.array[next_index].getUnit() != null:
					dijkstra_map.disable_point(next_index)
				else:
					final_move_blocked = false
			reactivate_all_points()
			battlemap._unit_overlay.draw(destination_path)
			return destination_path
		else:
			reactivate_all_points()
			return destination_path"""


func reactivate_all_points() -> void:
	#re-activate all points
	var index = 0
	for gamedata in gamegrid.array:
		if gamedata != null:
			dijkstra_map.enable_point(index)
		index += 1

func no_targets_direct_path(attacker : Unit) -> PoolVector2Array:
	var long_distance_coordinates : Array = []
	var destination_path : PoolVector2Array = []
	for unit in battlemap._units_node.get_children():
		if unit.playerOwner.team != attacker.playerOwner.team:
			if is_good_attack(attacker, unit):
				long_distance_coordinates.append(gamegrid.as_index(unit.cell))
	print (long_distance_coordinates)
	if not long_distance_coordinates.empty():
		var final_move_blocked = true
		while final_move_blocked:
			destination_path = []
			recalculate_to_targets_map(attacker.movement_type,long_distance_coordinates)
			# Set starting index
			destination_path.append(attacker.cell)
			var next_index = gamegrid.as_index(attacker.cell)
			var move_distance = dijkstra_map.get_cost_at_point(next_index)
			while move_distance - dijkstra_map.get_cost_at_point(next_index) < attacker.move_range:
				next_index = dijkstra_map.get_direction_at_point(next_index)
				destination_path.append(gamegrid.array[next_index].coordinates)
			# if the final destination coordinate is blocked
			if gamegrid.array[next_index].getUnit() != null:
				dijkstra_map.disable_point(next_index)
			else:
				final_move_blocked = false
		reactivate_all_points()
		battlemap._unit_overlay.draw(destination_path)
		return destination_path
	else:
		reactivate_all_points()
		battlemap._unit_overlay.draw(destination_path)
		return destination_path

func is_good_attack(attacker : Unit, defender : Unit) -> bool:
	var temp_max_damage = gamegrid.calculate_max_damage(attacker, defender)
	var temp_min_damage = gamegrid.calculate_min_damage(attacker, defender)
	var temp_damage = (temp_max_damage + temp_min_damage)/2.0
	#This attack is relying on luck rolls onl;y
	if temp_damage < 10 && defender.health > temp_damage:
		return false
	var funds_damage = temp_damage * 0.01 * defender.cost
	var funds_damage_recieved = 0
	print(String(attacker.cell) + " attacking " + String(defender.cell))
	print("Damage done" + String(temp_damage))
	if defender.attack_type == Constants.ATTACK_TYPE.DIRECT && attacker.attack_type == Constants.ATTACK_TYPE.DIRECT:
		var temp_max_damage_received = gamegrid.calculate_max_damage(defender, attacker, temp_damage)
		var temp_min_damage_recieved = gamegrid.calculate_min_damage(defender, attacker, temp_damage)
		var temp_damage_recieved = (temp_max_damage_received + temp_min_damage_recieved)/2.0
		# If the attacker will lose 80% of their remaining life in the attack
		print("Damage Recieved" + String(temp_damage_recieved))
		if temp_damage_recieved != 0:
			if temp_damage_recieved/attacker.health > 0.8:
				print("will almost die or will die")
				return false
		funds_damage_recieved = temp_damage_recieved * 0.01 * attacker.cost
		# Dont consider this a good trade
	print(String(funds_damage) + " vs. " + String(funds_damage_recieved*0.8))
	return funds_damage > funds_damage_recieved*0.8

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
