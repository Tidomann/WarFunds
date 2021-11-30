extends Node2D


var dijkstra_map
var dijkstra_map_dict
var infantry_map: DijkstraMap = DijkstraMap.new()
var mech_map: DijkstraMap = DijkstraMap.new()
var tires_map: DijkstraMap = DijkstraMap.new()
var tread_map: DijkstraMap = DijkstraMap.new()
var air_map: DijkstraMap = DijkstraMap.new()
export var gamegrid: Resource
var battlemap
var devtiles
var turn_queue
var soundmanager
var human_player
var gameboard
var buymenu
onready var timer = $Timer

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func take_computer_turn(computer : Node2D) -> void:
	battlemap.get_node("CanvasLayer/update-ui").visible = false
	var infantry : Array = []
	var mech : Array = []
	var light_direct : Array = []
	var direct : Array = []
	var indirect : Array = []
	for unit in battlemap._units_node.get_children():
		if not unit.turnReady || unit.playerOwner != computer:
			continue
		match unit.unit_referance:
			Constants.UNIT.JUNIOR:
				infantry.append(unit)
			Constants.UNIT.SENIOR:
				infantry.append(unit)
			Constants.UNIT.BAZOOKA_SENIOR:
				mech.append(unit)
			Constants.UNIT.SCANNER:
				light_direct.append(unit)
			Constants.UNIT.PRINTER:
				direct.append(unit)
			Constants.UNIT.STAPLER:
				indirect.append(unit)
			Constants.UNIT.FAX:
				indirect.append(unit)
			Constants.UNIT.TOWER:
				indirect.append(unit)
	timer.stop()
	timer.set_wait_time(2)
	timer.set_one_shot(true)
	timer.start()
	yield(timer, "timeout")
	if computer.commander.canUsePower():
		computer.commander.use_power()
		timer.set_wait_time(6)
		timer.set_one_shot(true)
		timer.start()
		yield(timer, "timeout")
	if not light_direct.empty():
		yield(direct_actions(light_direct), "completed")
	if computer.commander.canUsePower() && not computer.commander.used_power:
		computer.commander.use_power()
		timer.set_wait_time(6)
		timer.set_one_shot(true)
		timer.start()
		yield(timer, "timeout")
	if not indirect.empty():
		yield(indirect_actions(indirect), "completed")
	if not direct.empty():
		yield(direct_actions(direct), "completed")
	if not mech.empty():
		yield(infantry_actions(mech), "completed")
	if not infantry.empty():
		yield(infantry_actions(infantry), "completed")
	buy_units(computer)
	timer.set_wait_time(1.5)
	timer.set_one_shot(true)
	timer.start()
	yield(timer, "timeout")
	var temp_units = gamegrid.get_players_units(computer)
	if not temp_units.empty():
		for unit in temp_units:
			if not unit.is_turnReady():
				unit.flip_turnReady()
	if gameboard.is_game_finished(human_player):
		gameboard.end_game(human_player)
	else:
		turn_queue.nextTurn()
	battlemap.get_node("CanvasLayer/update-ui").visible = true

func init(inbattlemap : Node2D) -> void:
	dijkstra_map_dict = {
	Constants.MOVEMENT_TYPE.INFANTRY: infantry_map,
	Constants.MOVEMENT_TYPE.MECH: mech_map,
	Constants.MOVEMENT_TYPE.TIRES: tires_map,
	Constants.MOVEMENT_TYPE.TREAD: tread_map,
	Constants.MOVEMENT_TYPE.AIR: air_map,
	}
	battlemap = inbattlemap
	turn_queue = battlemap.get_node("TurnQueue")
	soundmanager = battlemap.get_node("GameBoard/SoundManager")
	human_player = battlemap.get_node("TurnQueue/Human")
	gameboard = battlemap.get_node("GameBoard")
	devtiles = gamegrid.devtiles
	buymenu = battlemap.get_node("BuyMenu")
	gamegrid = battlemap.gamegrid
	var index = 0
	for cell in gamegrid.array:
		if cell != null:
			infantry_map.add_point(index)
			mech_map.add_point(index)
			tires_map.add_point(index)
			tread_map.add_point(index)
			air_map.add_point(index)
		index += 1
	index = 0
	for cell in devtiles.get_used_cells():
		for direction in DIRECTIONS:
			var adjacent_coordinate: Vector2 = cell + direction
			if not gamegrid.is_gridcoordinate_within_map(adjacent_coordinate):
				continue
			if devtiles.get_cellv(adjacent_coordinate) != -1 && not infantry_map.has_connection(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate)):
				if gamegrid.has_property(adjacent_coordinate):
					infantry_map.connect_points(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate), 1.0, false)
				else:
					var tiletype = gamegrid.array[gamegrid.as_index(adjacent_coordinate)].tileType
					if gamegrid.is_valid_move(Constants.MOVEMENT_TYPE.INFANTRY,tiletype):
						var move_cost = float(gamegrid.get_movecost(Constants.MOVEMENT_TYPE.INFANTRY,tiletype))
						infantry_map.connect_points(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate), move_cost, false)
			if devtiles.get_cellv(adjacent_coordinate) != -1 && not mech_map.has_connection(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate)):
				if gamegrid.has_property(adjacent_coordinate):
					mech_map.connect_points(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate), 1.0, false)
				else:
					var tiletype = gamegrid.array[gamegrid.as_index(adjacent_coordinate)].tileType
					if gamegrid.is_valid_move(Constants.MOVEMENT_TYPE.MECH,tiletype):
						var move_cost = float(gamegrid.get_movecost(Constants.MOVEMENT_TYPE.MECH,tiletype))
						mech_map.connect_points(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate), move_cost, false)
			if devtiles.get_cellv(adjacent_coordinate) != -1 && not tires_map.has_connection(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate)):
				if gamegrid.has_property(adjacent_coordinate):
					tires_map.connect_points(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate), 1.0, false)
				else:
					var tiletype = gamegrid.array[gamegrid.as_index(adjacent_coordinate)].tileType
					if gamegrid.is_valid_move(Constants.MOVEMENT_TYPE.TIRES,tiletype):
						var move_cost = float(gamegrid.get_movecost(Constants.MOVEMENT_TYPE.TIRES,tiletype))
						tires_map.connect_points(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate), move_cost, false)
			if devtiles.get_cellv(adjacent_coordinate) != -1 && not tread_map.has_connection(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate)):
				if gamegrid.has_property(adjacent_coordinate):
					tread_map.connect_points(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate), 1.0, false)
				else:
					var tiletype = gamegrid.array[gamegrid.as_index(adjacent_coordinate)].tileType
					if gamegrid.is_valid_move(Constants.MOVEMENT_TYPE.TREAD,tiletype):
						var move_cost = float(gamegrid.get_movecost(Constants.MOVEMENT_TYPE.TREAD,tiletype))
						tread_map.connect_points(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate), move_cost, false)
			if devtiles.get_cellv(adjacent_coordinate) != -1 && not air_map.has_connection(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate)):
				if gamegrid.has_property(adjacent_coordinate):
					air_map.connect_points(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate), 1.0, false)
				else:
					var tiletype = gamegrid.array[gamegrid.as_index(adjacent_coordinate)].tileType
					if gamegrid.is_valid_move(Constants.MOVEMENT_TYPE.AIR,tiletype):
						var move_cost = float(gamegrid.get_movecost(Constants.MOVEMENT_TYPE.AIR,tiletype))
						air_map.connect_points(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate), move_cost, false)

func recalculate_map(unit : Unit, cell : Vector2) -> void:
	var movement_type = unit.movement_type
	dijkstra_map = dijkstra_map_dict[movement_type]
	var optional_params = {
		"input_is_destination": false,
		"terrain_weights": { -1: 1.0 },
	}
	dijkstra_map.recalculate(gamegrid.as_index(cell), optional_params)

func recalculate_air_map(_unit : Unit, cell : Vector2) -> void:
	var optional_params = {
		"input_is_destination": false,
		"terrain_weights": { -1: 1.0 },
	}
	air_map.recalculate(gamegrid.as_index(cell), optional_params)
	
func recalculate_to_targets_map(unit: Unit, array : Array) -> void:
	var movement_type = unit.movement_type
	dijkstra_map = dijkstra_map_dict[movement_type]
	var optional_params = {
		"input_is_destination": true,
		"terrain_weights": { -1: 1.0 },
	}
	dijkstra_map.recalculate(array, optional_params)

func recalculate_to_targets_air_map(_unit: Unit, array : Array) -> void:
	var optional_params = {
		"input_is_destination": true,
		"terrain_weights": { -1: 1.0 },
	}
	air_map.recalculate(array, optional_params)

func best_attack_path_direct(attacker : Unit) -> PoolVector2Array:
	recalculate_map(attacker, attacker.cell)
	recalculate_air_map(attacker, attacker.cell)
	dijkstra_map = dijkstra_map_dict[attacker.movement_type]
	var move_bonus = attacker.playerOwner.commander.move_bonus()
	var test_movement = attacker.move_range + move_bonus + 1.0
	var dijkstra_tiles = air_map.get_all_points_with_cost_between(0.0, test_movement)
	var test_array : Array = []
	for index in dijkstra_tiles:
		test_array.append(gamegrid.array[index].coordinates)
	#battlemap._unit_overlay.draw(test_array)
	var target_list : Array = []
	for unit in battlemap._units_node.get_children():
		if test_array.has(unit.cell):
			if unit.playerOwner.team != attacker.playerOwner.team:
				if is_good_attack(attacker, unit) || (attacker.unit_type != Constants.UNIT_TYPE.INFANTRY && unit.unit_type == Constants.UNIT_TYPE.INFANTRY):
					target_list.append(unit)
	if not target_list.empty():
		# Disable Movement through enemies
		for unit in battlemap._units_node.get_children():
			# Attacker cannot travel on top of enemy
			if attacker.playerOwner.team != unit.playerOwner.team:
				dijkstra_map = dijkstra_map_dict[attacker.movement_type]
				dijkstra_map.disable_point(gamegrid.as_index(unit.cell))
				dijkstra_map.set_terrain_for_point(gamegrid.as_index(unit.cell), 1)
		recalculate_map(attacker, attacker.cell)
		dijkstra_map = dijkstra_map_dict[attacker.movement_type]
		# can we reach each target in the target_list
		var reachable_targets : Array = []
		# Check all possible targets
		for target in target_list:
			for direction in DIRECTIONS:
				if not gamegrid.is_gridcoordinate_within_map(target.cell + direction):
					continue
				# Do we have a path next to the targets if we are blocked by enemy units and
				# is the end of that path not occupied already
				if not dijkstra_map.get_shortest_path_from_point(gamegrid.as_index(target.cell + direction)).empty() &&\
				not gamegrid.is_occupied(target.cell + direction):
					if not reachable_targets.has(target) && dijkstra_map.get_cost_at_point(gamegrid.as_index(target.cell + direction)) <= attacker.move_range:
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
						if funds_damage < funds_damage_recieved * 0.8 && (best_target != null && target.health <= attacker.health):
							continue
					max_funds_damage = funds_damage
					best_target = target
			# No targets are viable, or the only targets we have are stronger than us
			if best_target == null:
				reactivate_all_points()
				return no_targets_direct_path(attacker)
			var best_defense = 0
			var destination = null
			for direction in DIRECTIONS:
				if not gamegrid.is_gridcoordinate_within_map(best_target.cell + direction):
					continue
				if not dijkstra_map.get_shortest_path_from_point(gamegrid.as_index(best_target.cell + direction)).empty() &&\
				not gamegrid.is_occupied(best_target.cell + direction):
						if destination == null:
							if dijkstra_map.get_cost_at_point(gamegrid.as_index(best_target.cell + direction)) <= attacker.move_range:
								best_defense = gamegrid.get_terrain_bonus(gamegrid.array[gamegrid.as_index(best_target.cell + direction)])
								destination = best_target.cell + direction
						else:
							if best_defense < gamegrid.get_terrain_bonus(gamegrid.array[gamegrid.as_index(best_target.cell + direction)]) &&\
							dijkstra_map.get_cost_at_point(gamegrid.as_index(best_target.cell + direction)) <= attacker.move_range:
								best_defense = gamegrid.get_terrain_bonus(gamegrid.array[gamegrid.as_index(best_target.cell + direction)])
								destination = best_target.cell + direction
			var destination_path : PoolVector2Array = []
			var dijkstra_path = dijkstra_map.get_shortest_path_from_point(gamegrid.as_index(destination))
			for n in range(dijkstra_path.size()-1,-1,-1):
				destination_path.append(gamegrid.array[dijkstra_path[n]].coordinates)
			destination_path.append(destination)
			reactivate_all_points()
			#battlemap._unit_overlay.draw(destination_path)
			return destination_path
		# no reachable targets within range
		# points are still disabled at this point
		else:
			reactivate_all_points()
			return no_targets_direct_path(attacker)
	# no targets within range
	else:
		reactivate_all_points()
		return no_targets_direct_path(attacker)


func reactivate_all_points() -> void:
	#re-activate all points
	var index = 0
	for gamedata in gamegrid.array:
		if gamedata != null:
			infantry_map.enable_point(index)
			mech_map.enable_point(index)
			tires_map.enable_point(index)
			tread_map.enable_point(index)
			air_map.enable_point(index)
			infantry_map.set_terrain_for_point(index, -1)
			mech_map.set_terrain_for_point(index, -1)
			tires_map.set_terrain_for_point(index, -1)
			tread_map.set_terrain_for_point(index, -1)
			air_map.set_terrain_for_point(index, -1)
		index += 1

func no_targets_direct_path(attacker : Unit) -> PoolVector2Array:
	if not attacker.unit_type == Constants.UNIT_TYPE.INFANTRY:
		var long_distance_coordinates : Array = []
		var destination_path : PoolVector2Array = []
		for unit in battlemap._units_node.get_children():
			if unit.playerOwner.team != attacker.playerOwner.team:
				if is_good_attack(attacker, unit):
					long_distance_coordinates.append(gamegrid.as_index(unit.cell))
		if not long_distance_coordinates.empty():
			var final_move_blocked = true
			while final_move_blocked:
				destination_path = []
				recalculate_to_targets_map(attacker,long_distance_coordinates)
				dijkstra_map = dijkstra_map_dict[attacker.movement_type]
				# Set starting index
				destination_path.append(attacker.cell)
				var next_index = gamegrid.as_index(attacker.cell)
				var move_distance = dijkstra_map.get_cost_at_point(next_index)
				var move_bonus = attacker.playerOwner.commander.move_bonus()
				while move_distance - dijkstra_map.get_cost_at_point(next_index) < (attacker.move_range + move_bonus):
					if next_index == dijkstra_map.get_direction_at_point(next_index):
						break
					next_index = dijkstra_map.get_direction_at_point(next_index)
					destination_path.append(gamegrid.array[next_index].coordinates)
				# if the final destination coordinate is blocked
				if gamegrid.array[next_index].getUnit() != null:
					if gamegrid.array[next_index].getUnit() != attacker:
						dijkstra_map = dijkstra_map_dict[attacker.movement_type]
						dijkstra_map.disable_point(next_index)
						dijkstra_map.set_terrain_for_point(next_index, 1)
					else:
						final_move_blocked = false
				else:
					final_move_blocked = false
			reactivate_all_points()
			#battlemap._unit_overlay.draw(destination_path)
			return destination_path
		else:
			reactivate_all_points()
			#battlemap._unit_overlay.draw(destination_path)
			return destination_path
	#Capture path
	else:
		var property_coordinates : PoolIntArray = []
		var destination_path : PoolVector2Array = []
		for cell in gamegrid.propertytiles.get_used_cells():
			if gamegrid.array[gamegrid.as_index(cell)].property.playerOwner != attacker.playerOwner:
				if gamegrid.array[gamegrid.as_index(cell)].unit != null:
					if not gamegrid.array[gamegrid.as_index(cell)].unit == attacker.playerOwner:
						property_coordinates.append(gamegrid.as_index(cell))
				else:
					property_coordinates.append(gamegrid.as_index(cell))
		if not property_coordinates.empty():
			var final_move_blocked = true
			while final_move_blocked:
				destination_path = []
				recalculate_to_targets_map(attacker, property_coordinates)
				dijkstra_map = dijkstra_map_dict[attacker.movement_type]
				# Set starting index
				destination_path.append(attacker.cell)
				var next_index = gamegrid.as_index(attacker.cell)
				var move_distance = dijkstra_map.get_cost_at_point(next_index)
				var move_bonus = attacker.playerOwner.commander.move_bonus()
				while move_distance - dijkstra_map.get_cost_at_point(next_index) < (attacker.move_range + move_bonus):
					if next_index == dijkstra_map.get_direction_at_point(next_index):
						break
					next_index = dijkstra_map.get_direction_at_point(next_index)
					destination_path.append(gamegrid.array[next_index].coordinates)
				# if the final destination coordinate is blocked
				if gamegrid.array[next_index].getUnit() != null:
					if gamegrid.array[next_index].getUnit() != attacker:
						dijkstra_map = dijkstra_map_dict[attacker.movement_type]
						dijkstra_map.disable_point(next_index)
						dijkstra_map.set_terrain_for_point(next_index, 1)
					else:
						final_move_blocked = false
				else:
					final_move_blocked = false
			reactivate_all_points()
			#battlemap._unit_overlay.draw(destination_path)
			return destination_path
		else:
			reactivate_all_points()
			#battlemap._unit_overlay.draw(destination_path)
			return destination_path

func no_targets_indirect_path(attacker: Unit) -> PoolVector2Array:
	var long_distance_coordinates : Array = []
	var destination_path : PoolVector2Array = []
	dijkstra_map = dijkstra_map_dict[attacker.movement_type]
	reactivate_all_points()
	for unit in battlemap._units_node.get_children():
		if unit.playerOwner.team != attacker.playerOwner.team:
			long_distance_coordinates.append(gamegrid.as_index(unit.cell))
			#air_map.disable_point(gamegrid.as_index(unit.cell))
			#air_map.set_terrain_for_point(gamegrid.as_index(unit.cell), 1)
			#dijkstra_map = dijkstra_map_dict[attacker.movement_type]
			#dijkstra_map.disable_point(gamegrid.as_index(unit.cell))
			#dijkstra_map.set_terrain_for_point(gamegrid.as_index(unit.cell), 1)
	if not long_distance_coordinates.empty():
		var final_move_blocked = true
		while final_move_blocked:
			destination_path = []
			recalculate_to_targets_map(attacker,long_distance_coordinates)
			recalculate_to_targets_air_map(attacker,long_distance_coordinates)
			destination_path.append(attacker.cell)
			var next_index = gamegrid.as_index(attacker.cell)
			var move_distance = dijkstra_map.get_cost_at_point(next_index)
			var move_bonus = attacker.playerOwner.commander.move_bonus()
			while move_distance - dijkstra_map.get_cost_at_point(next_index) < (attacker.move_range + move_bonus):
				if next_index == dijkstra_map.get_direction_at_point(next_index):
					break
				if air_map.get_cost_at_point(next_index) <= attacker.atk_range && \
				air_map.get_cost_at_point(next_index) > attacker.min_atk_range && \
				dijkstra_map.get_cost_at_point(next_index) <= attacker.move_range:
					break
				# What is this logic why does it work though
				if not gamegrid.is_occupied(gamegrid.array[dijkstra_map.get_direction_at_point(next_index)].coordinates):
					next_index = dijkstra_map.get_direction_at_point(next_index)
				else:
					break
				destination_path.append(gamegrid.array[next_index].coordinates)
			# if the final destination coordinate is blocked
			if gamegrid.array[next_index].getUnit() != null:
				if gamegrid.array[next_index].getUnit() != attacker:
					air_map.disable_point(next_index)
					dijkstra_map = dijkstra_map_dict[attacker.movement_type]
					dijkstra_map.disable_point(next_index)
					dijkstra_map.set_terrain_for_point(next_index, 1)
				else:
					final_move_blocked = false
			else:
				final_move_blocked = false
		reactivate_all_points()
		#battlemap._unit_overlay.draw(destination_path)
		return destination_path
	# no targets to find
	else:
		reactivate_all_points()
		#battlemap._unit_overlay.draw(destination_path)
		return destination_path

func defensive_direct(attacker: Unit) -> PoolVector2Array:
	recalculate_map(attacker, attacker.cell)
	dijkstra_map = dijkstra_map_dict[attacker.movement_type]
	var move_bonus = attacker.playerOwner.commander.move_bonus()
	var test_movement = attacker.move_range + move_bonus + 3.0
	var dijkstra_tiles = dijkstra_map.get_all_points_with_cost_between(0.0, test_movement)
	var test_array : Array = []
	for index in dijkstra_tiles:
		test_array.append(gamegrid.array[index].coordinates)
	var target_list : Array = []
	for unit in battlemap._units_node.get_children():
		if test_array.has(unit.cell):
			if unit.playerOwner.team != attacker.playerOwner.team:
				if is_good_attack(attacker, unit):
					target_list.append(unit)
	# Disable Movement through enemies
	for unit in battlemap._units_node.get_children():
		# Attacker cannot travel on top of enemy
		if attacker.playerOwner.team != unit.playerOwner.team:
			dijkstra_map = dijkstra_map_dict[attacker.movement_type]
			dijkstra_map.disable_point(gamegrid.as_index(unit.cell))
			dijkstra_map.set_terrain_for_point(gamegrid.as_index(unit.cell), 1)
	recalculate_map(attacker, attacker.cell)
	dijkstra_map = dijkstra_map_dict[attacker.movement_type]
	# can we reach each target in the target_list
	if not target_list.empty():
		var reachable_targets : Array = []
		# Check all possible targets
		for target in target_list:
			for direction in DIRECTIONS:
				if not gamegrid.is_gridcoordinate_within_map(target.cell + direction):
					continue
				# Do we have a path next to the targets if we are blocked by enemy units and
				# is the end of that path not occupied already
				if not dijkstra_map.get_shortest_path_from_point(gamegrid.as_index(target.cell + direction)).empty() || (target.cell + direction) == attacker.cell:
					if not gamegrid.is_occupied(target.cell + direction) || gamegrid.get_unit(target.cell + direction) == attacker:
						if not reachable_targets.has(target) && dijkstra_map.get_cost_at_point(gamegrid.as_index(target.cell + direction)) <= attacker.move_range:
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
				if not dijkstra_map.get_shortest_path_from_point(gamegrid.as_index(best_target.cell + direction)).empty() || (best_target.cell + direction) == attacker.cell:
					if not gamegrid.is_occupied(best_target.cell + direction) || gamegrid.get_unit(best_target.cell + direction) == attacker:
						if destination == null:
							if dijkstra_map.get_cost_at_point(gamegrid.as_index(best_target.cell + direction)) <= attacker.move_range:
								best_defense = gamegrid.get_terrain_bonus(gamegrid.array[gamegrid.as_index(best_target.cell + direction)])
								destination = best_target.cell + direction
						else:
							if best_defense < gamegrid.get_terrain_bonus(gamegrid.array[gamegrid.as_index(best_target.cell + direction)]) &&\
							dijkstra_map.get_cost_at_point(gamegrid.as_index(best_target.cell + direction)) <= attacker.move_range:
								best_defense = gamegrid.get_terrain_bonus(gamegrid.array[gamegrid.as_index(best_target.cell + direction)])
								destination = best_target.cell + direction
			var destination_path : PoolVector2Array = []
			var dijkstra_path = dijkstra_map.get_shortest_path_from_point(gamegrid.as_index(destination))
			for n in range(dijkstra_path.size()-1,-1,-1):
				destination_path.append(gamegrid.array[dijkstra_path[n]].coordinates)
			destination_path.append(destination)
			reactivate_all_points()
			attacker.defensive_ai = false
			#battlemap._unit_overlay.draw(destination_path)
			return destination_path
		else:
			reactivate_all_points()
			var destination_path : PoolVector2Array = []
			return destination_path
	else:
		reactivate_all_points()
		var destination_path : PoolVector2Array = []
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
	if defender.attack_type == Constants.ATTACK_TYPE.DIRECT && attacker.attack_type == Constants.ATTACK_TYPE.DIRECT:
		var temp_max_damage_received = gamegrid.calculate_max_damage(defender, attacker, temp_damage)
		var temp_min_damage_recieved = gamegrid.calculate_min_damage(defender, attacker, temp_damage)
		var temp_damage_recieved = (temp_max_damage_received + temp_min_damage_recieved)/2.0
		# If the attacker will lose 80% of their remaining life in the attack
		if temp_damage_recieved != 0:
			if temp_damage_recieved/attacker.health > 0.8:
				return false
		funds_damage_recieved = temp_damage_recieved * 0.01 * attacker.cost
		# Dont consider this a good trade
	return funds_damage > funds_damage_recieved*0.8

func direct_actions(light_direct : Array) -> void:
	for unit in light_direct:
		if (unit.health < 29 || unit.ai_healing) && has_open_property(unit):
			unit.ai_healing = true
			var path = get_healing_path(unit)
			move_computer_unit(unit,path)
			if path.size() > 1:
				yield(unit, "walk_finished")
				soundmanager.stopallsound()
			else:
				if gameboard.can_afford_heal(unit) && gamegrid.has_property(unit.cell):
					if gamegrid.get_property(unit.cell).playerOwner == unit.playerOwner:
						soundmanager.playsound("Heal")
						# ADJUST HEALING COST BALANCE HERE
						unit.playerOwner.addFunds(-unit.get_healing(100) * 2)
						if unit.turnReady:
							unit.flip_turnReady()
						timer.set_wait_time(1.9)
						timer.set_one_shot(true)
						timer.start()
						yield(timer, "timeout")
			if unit.turnReady:
				unit.flip_turnReady()
		else:
			if not unit.defensive_ai:
				var path = best_attack_path_direct(unit)
				var old_position = unit.cell
				move_computer_unit(unit, path)
				if path.size() > 1 || gamegrid.enemy_in_range(unit, old_position, old_position):
					if path.size() > 1:
						yield(unit, "walk_finished")
						soundmanager.stopallsound()
					var new_position = unit.cell
					if gamegrid.enemy_in_range(unit, old_position, new_position):
						var targets = []
						for direction in DIRECTIONS:
							var coordinates: Vector2 = new_position + direction
							if gamegrid.is_gridcoordinate_within_map(coordinates):
								if gamegrid.is_occupied(coordinates):
									if gamegrid.is_enemy(unit, gamegrid.get_unit(coordinates)):
										targets.append(gamegrid.get_unit(coordinates))
						if targets.size() > 1:
							var best_target = get_best_target(unit, targets)
							if not best_target == null:
								yield(computer_combat(unit, best_target), "completed")
						else:
							yield(computer_combat(unit, targets[0]), "completed")
					else:
						if unit.turnReady:
							unit.flip_turnReady()
				else:
					if (unit.health < 100):
						var heal_path = get_healing_path(unit)
						move_computer_unit(unit,heal_path)
						if heal_path.size() > 1:
							yield(unit, "walk_finished")
							soundmanager.stopallsound()
						else:
							if gameboard.can_afford_heal(unit) && gamegrid.has_property(unit.cell):
								if gamegrid.get_property(unit.cell).playerOwner == unit.playerOwner:
									soundmanager.playsound("Heal")
									# ADJUST HEALING COST BALANCE HERE
									unit.playerOwner.addFunds(-unit.get_healing(100) * 2)
									if unit.turnReady:
										unit.flip_turnReady()
									timer.set_wait_time(1.9)
									timer.set_one_shot(true)
									timer.start()
									yield(timer, "timeout")
						if unit.turnReady:
							unit.flip_turnReady()
					else:
						if unit.turnReady:
							unit.flip_turnReady()
			else:
				#print(unit.cell)
				var path = defensive_direct(unit)
				var old_position = unit.cell
				move_computer_unit(unit, path)
				if path.size() > 1:
					yield(unit, "walk_finished")
					soundmanager.stopallsound()
				var new_position = unit.cell
				if gamegrid.enemy_in_range(unit, old_position, new_position):
					var targets = []
					for direction in DIRECTIONS:
						var coordinates: Vector2 = new_position + direction
						if gamegrid.is_gridcoordinate_within_map(coordinates):
							if gamegrid.is_occupied(coordinates):
								if gamegrid.is_enemy(unit, gamegrid.get_unit(coordinates)):
									targets.append(gamegrid.get_unit(coordinates))
					if targets.size() > 1:
						var best_target = get_best_target(unit, targets)
						if not best_target == null:
							yield(computer_combat(unit, best_target), "completed")
					else:
						yield(computer_combat(unit, targets[0]), "completed")
				else:
					if unit.turnReady:
						unit.flip_turnReady()
		timer.stop()
		timer.set_wait_time(1.0)
		timer.set_one_shot(true)
		timer.start()
		yield(timer, "timeout")

func infantry_actions(infantry : Array) -> void:
	for unit in infantry:
		var path = defensive_direct(unit)
		var old_position = unit.cell
		if path.size() > 1:
			if not path[0] == path[path.size()-1]:
				move_computer_unit(unit,path)
				yield(unit, "walk_finished")
				soundmanager.stopallsound()
			soundmanager.stopallsound()
			var new_position = unit.cell
			if gamegrid.enemy_in_range(unit, old_position, new_position):
						var targets = []
						for direction in DIRECTIONS:
							var coordinates: Vector2 = new_position + direction
							if gamegrid.is_gridcoordinate_within_map(coordinates):
								if gamegrid.is_occupied(coordinates):
									if gamegrid.is_enemy(unit, gamegrid.get_unit(coordinates)):
										targets.append(gamegrid.get_unit(coordinates))
						if targets.size() > 1:
							var best_target = get_best_target(unit, targets)
							if not best_target == null:
								yield(computer_combat(unit, best_target), "completed")
						else:
							yield(computer_combat(unit, targets[0]), "completed")
			else:
				if unit.turnReady:
					unit.flip_turnReady()
		else:
			move_computer_unit(unit,path)
			if unit.defensive_ai:
				if unit.turnReady:
					unit.flip_turnReady()
			else:
				reactivate_all_points()
				for enemy in battlemap._units_node.get_children():
					# Attacker cannot travel on top of enemy
						if unit.playerOwner.team != enemy.playerOwner.team:
							if not gamegrid.has_property(enemy.cell):
								dijkstra_map = dijkstra_map_dict[unit.movement_type]
								dijkstra_map.disable_point(gamegrid.as_index(enemy.cell))
								dijkstra_map.set_terrain_for_point(gamegrid.as_index(enemy.cell), 1)
				path = no_targets_direct_path(unit)
				move_computer_unit(unit,path)
				if path.size() > 1:
					yield(unit, "walk_finished")
					soundmanager.stopallsound()
				timer.set_wait_time(1)
				timer.set_one_shot(true)
				timer.start()
				if gamegrid.has_property(unit.cell):
					var previous_owner = gamegrid.get_property(unit.cell).playerOwner
					if gamegrid.get_property(unit.cell).playerOwner != unit.playerOwner:
						if gamegrid.get_property(unit.cell).capture(unit):
							#TODO: add capture sounds AI
							if unit.get_unit_team() == human_player.team:
								soundmanager.playsound("CaptureCompleteGood")
							else:
								soundmanager.playsound("CaptureCompleteBad")
							get_parent().set_property(unit.cell, unit.playerOwner)
							var signaled_income = gamegrid.calculate_income(previous_owner)
							gameboard.emit_signal("income_changed", previous_owner, signaled_income)
							signaled_income = gamegrid.calculate_income(unit.playerOwner)
							gameboard.emit_signal("income_changed", unit.playerOwner, signaled_income)
						else:
							soundmanager.playsound("CaptureIncomplete")
				if unit.turnReady:
					unit.flip_turnReady()
		timer.set_wait_time(1.0)
		timer.set_one_shot(true)
		timer.start()
		yield(timer, "timeout")

func indirect_actions(indirects : Array) -> void:
	for unit in indirects:
		reactivate_all_points()
		# targets in range at start of turn
		if gamegrid.enemy_in_range(unit, unit.cell, unit.cell):
			var targets = []
			var attackable_cells = gamegrid.get_attackable_cells(unit)
			for cell in attackable_cells:
				if gamegrid.is_occupied(cell):
					if gamegrid.is_enemy(unit, gamegrid.get_unit(cell)):
						targets.append(gamegrid.get_unit(cell))
			var best_target
			best_target = get_best_target(unit, targets)
			if not best_target == null:
				# Maybe indirect can stay defensive?
				unit.defensive_ai = false
				yield(computer_combat(unit, best_target), "completed")
			else:
				# Maybe indirect can stay defensive?
				unit.defensive_ai = false
				yield(computer_combat(unit, targets[0]), "completed")
		# no targets in range
		else:
			var path : PoolVector2Array = []
			if (unit.health < 29 || unit.ai_healing) && has_open_property(unit):
				unit.ai_healing = true
				path = get_healing_path(unit)
				if path.size() <= 1:
					if gameboard.can_afford_heal(unit) && gamegrid.has_property(unit.cell):
						if gamegrid.get_property(unit.cell).playerOwner == unit.playerOwner:
							soundmanager.playsound("Heal")
							unit.playerOwner.addFunds(-unit.get_healing(100) * 2)
							if unit.turnReady:
								unit.flip_turnReady()
							timer.set_wait_time(1.9)
							timer.set_one_shot(true)
							timer.start()
							yield(timer, "timeout")
			else:
				if not unit.defensive_ai:
					path = no_targets_indirect_path(unit)
			move_computer_unit(unit,path)
			if path.size() > 1:
				yield(unit, "walk_finished")
				soundmanager.stopallsound()
			if unit.turnReady:
				unit.flip_turnReady()
		timer.stop()
		timer.set_wait_time(1)
		timer.set_one_shot(true)
		timer.start()
		yield(timer, "timeout")

func move_computer_unit(unit : Unit, path : PoolVector2Array) -> void:
	if path.size() > 1:
		unit.walk_along(path)
		gamegrid.array[gamegrid.as_index(path[0])].unit = null
		gamegrid.array[gamegrid.as_index(path[path.size()-1])].unit = unit
		unit.cell = path[path.size()-1]
		match unit.movement_type:
			Constants.MOVEMENT_TYPE.INFANTRY:
				soundmanager.playsound("InfantryMove")
			Constants.MOVEMENT_TYPE.MECH:
				soundmanager.playsound("InfantryMove")
			Constants.MOVEMENT_TYPE.TREAD:
				pass
			Constants.MOVEMENT_TYPE.TIRES:
				pass

func get_best_target(attacker : Unit, targets : Array) -> Unit:
	if targets.size() == 0:
		return null
	if targets.size() == 1:
		return targets[0]
	var funds_damage = 0
	var best_target : Unit
	for defender in targets:
		if is_good_attack(attacker, defender):
			var temp_max_damage = gamegrid.calculate_max_damage(attacker, defender)
			var temp_min_damage = gamegrid.calculate_min_damage(attacker, defender)
			var temp_damage = (temp_max_damage + temp_min_damage)/2.0
			var temp_funds_damage = temp_damage * 0.01 * defender.cost
			if funds_damage < temp_funds_damage || best_target == null:
				funds_damage = temp_funds_damage
				best_target = defender
	return best_target

func computer_combat(attacker : Unit, defender : Unit) -> void:
	var screen_position = devtiles.map_to_world(defender.cell)
	screen_position.x += devtiles.cell_size.x/2
	screen_position.y += devtiles.cell_size.y/2
	self.position = screen_position
	self.visible = true
	timer.stop()
	timer.set_wait_time(1.5)
	timer.set_one_shot(true)
	timer.start()
	yield(timer, "timeout")
	gamegrid.unit_combat(attacker, defender)
	soundmanager.playsound("Attack")
	self.visible = false
	if attacker.turnReady:
		attacker.flip_turnReady()

func get_healing_path(attacker: Unit) -> PoolVector2Array:
	var property_coordinates : PoolIntArray = []
	var destination_path : PoolVector2Array = []
	for cell in gamegrid.propertytiles.get_used_cells():
			if gamegrid.array[gamegrid.as_index(cell)].property.playerOwner == attacker.playerOwner:
				if gamegrid.array[gamegrid.as_index(cell)].unit != null:
					if gamegrid.array[gamegrid.as_index(cell)].unit != attacker:
						property_coordinates.append(gamegrid.as_index(cell))
					# unit is already on a property
					else:
						destination_path = []
						destination_path.append(attacker.cell)
						#battlemap._unit_overlay.draw(destination_path)
						return destination_path
				else:
					property_coordinates.append(gamegrid.as_index(cell))
	if not property_coordinates.empty():
		reactivate_all_points()
		# Disable Movement through enemies
		for enemy in battlemap._units_node.get_children():
			# Attacker cannot travel on top of enemy
			if enemy.playerOwner.team != attacker.playerOwner.team:
				dijkstra_map = dijkstra_map_dict[attacker.movement_type]
				dijkstra_map.disable_point(gamegrid.as_index(enemy.cell))
				dijkstra_map.set_terrain_for_point(gamegrid.as_index(enemy.cell), 1)
		var final_move_blocked = true
		while final_move_blocked:
			destination_path = []
			recalculate_to_targets_map(attacker, property_coordinates)
			dijkstra_map = dijkstra_map_dict[attacker.movement_type]
			# Set starting index
			destination_path.append(attacker.cell)
			var next_index = gamegrid.as_index(attacker.cell)
			var move_distance = dijkstra_map.get_cost_at_point(next_index)
			var move_bonus = attacker.playerOwner.commander.move_bonus()
			while move_distance - dijkstra_map.get_cost_at_point(next_index) < (attacker.move_range + move_bonus):
				if next_index == dijkstra_map.get_direction_at_point(next_index):
						break
				next_index = dijkstra_map.get_direction_at_point(next_index)
				destination_path.append(gamegrid.array[next_index].coordinates)
			# if the final destination coordinate is blocked
			if gamegrid.array[next_index].getUnit() != null:
				if gamegrid.array[next_index].getUnit() != attacker:
					dijkstra_map = dijkstra_map_dict[attacker.movement_type]
					dijkstra_map.disable_point(next_index)
					dijkstra_map.set_terrain_for_point(next_index, 1)
				else:
					final_move_blocked = false
			else:
				final_move_blocked = false
		reactivate_all_points()
		#battlemap._unit_overlay.draw(destination_path)
		return destination_path
	else:
		reactivate_all_points()
		destination_path = []
		destination_path.append(attacker.cell)
		#battlemap._unit_overlay.draw(destination_path)
		return destination_path

func has_open_property(attacker: Unit) -> bool:
	for cell in gamegrid.propertytiles.get_used_cells():
		if gamegrid.array[gamegrid.as_index(cell)].property.playerOwner == attacker.playerOwner:
			if gamegrid.array[gamegrid.as_index(cell)].unit != null:
				if gamegrid.array[gamegrid.as_index(cell)].unit == attacker:
					return true
			else:
				return true
	return false

func buy_units(computer: Node2D) -> void:
	var usable_bases: Array = []
	var enemy_hqs: Array = []
	var sorted_bases: Array = []
	reactivate_all_points()
	for data in gamegrid.array:
		if data != null:
			if data.property != null:
				if data.property.property_referance == Constants.PROPERTY.HQ && data.property.playerOwner.team != computer.team:
					enemy_hqs.append(gamegrid.as_index(data.property.cell))
				if data.property.property_referance == Constants.PROPERTY.BASE && data.property.playerOwner == computer && data.unit == null:
					usable_bases.append(data.property.cell)
	if not enemy_hqs.empty():
		var optional_params = {
			"input_is_destination": true,
			"terrain_weights": { -1: 1.0 },
		}
		air_map.recalculate(enemy_hqs, optional_params)
	if not usable_bases.empty():
		for base in usable_bases:
			sorted_bases.append([air_map.get_cost_at_point(gamegrid.as_index(base)), base])
	if not sorted_bases.empty():
		sorted_bases.sort_custom(baseSorter, "sort_ascending")
		for n in range(0, sorted_bases.size()):
			var unitreferance = buy_which_unit(computer, sorted_bases, n)
			if unitreferance != -1:
				buy_unit(computer, unitreferance, sorted_bases[n][1])

func buy_which_unit(computer: Node2D, bases: Array, index: int) -> int:
	var infantry_count = 0
	var printer_count = 0
	var scanner_count = 0
	var book_count = 0
	for unit in battlemap._units_node.get_children():
		if unit.unit_type == Constants.UNIT_TYPE.INFANTRY && unit.playerOwner == computer:
			infantry_count += 1
		if unit.unit_referance == Constants.UNIT.PRINTER && unit.playerOwner == computer:
			printer_count += 1
		if unit.unit_referance == Constants.UNIT.BAZOOKA_SENIOR && unit.playerOwner == computer:
			book_count += 1
		if unit.unit_referance == Constants.UNIT.SCANNER && unit.playerOwner == computer:
			scanner_count += 1
	# if the amount of bases we have left is equal or less than the amount
	# we need to at least have 5 infantry
	if bases.size()-index <= 4-infantry_count:
		if (4-infantry_count)*buymenu.bseniorcost < computer.funds:
			return Constants.UNIT.BAZOOKA_SENIOR
		if (4-infantry_count)*buymenu.seniorcost < computer.funds:
			return Constants.UNIT.SENIOR
		if (4-infantry_count)*buymenu.juniorcost < computer.funds:
			return Constants.UNIT.JUNIOR
	# We have more bases than the amount of infantry we need to buy
	var funds_after_reserve = computer.funds
	# reserve money to at least buy the amount of juniors we need
	if (4-infantry_count) > 0:
		funds_after_reserve -= (4-infantry_count)*buymenu.juniorcost
	if printer_count < 5 && funds_after_reserve > buymenu.printercost:
		return Constants.UNIT.PRINTER
	# Have at least 5 printers, and will be able to get at least 5 infantry
	if funds_after_reserve > buymenu.faxcost && printer_count >= 5:
		return Constants.UNIT.FAX
	if funds_after_reserve > buymenu.printercost:
		return Constants.UNIT.PRINTER
	if funds_after_reserve > buymenu.staplercost && printer_count >= 3:
		return Constants.UNIT.STAPLER
	if funds_after_reserve > buymenu.scannercost && book_count < scanner_count:
		return Constants.UNIT.SCANNER
	if funds_after_reserve > buymenu.bseniorcost:
		return Constants.UNIT.BAZOOKA_SENIOR
	if funds_after_reserve > buymenu.seniorcost:
		return Constants.UNIT.SENIOR
	if funds_after_reserve > buymenu.juniorcost:
		return Constants.UNIT.JUNIOR
	return -1

func buy_unit(computer: Node2D, unit_referance: int, coordinates: Vector2) -> void:
	var previous_player = buymenu.player
	var previous_grid_position = buymenu.grid_position
	match unit_referance:
		Constants.UNIT.JUNIOR:
			buymenu.player = computer
			buymenu.grid_position = coordinates
			buymenu._on_JuniorButton_pressed()
		Constants.UNIT.SENIOR:
			buymenu.player = computer
			buymenu.grid_position = coordinates
			buymenu._on_SeniorButton_pressed()
		Constants.UNIT.BAZOOKA_SENIOR:
			buymenu.player = computer
			buymenu.grid_position = coordinates
			buymenu._on_bSeniorButton_pressed()
		Constants.UNIT.SCANNER:
			buymenu.player = computer
			buymenu.grid_position = coordinates
			buymenu._on_ScannerButton_pressed()
		Constants.UNIT.STAPLER:
			buymenu.player = computer
			buymenu.grid_position = coordinates
			buymenu._on_Staplerbutton_pressed()
		Constants.UNIT.PRINTER:
			buymenu.player = computer
			buymenu.grid_position = coordinates
			buymenu._on_PrinterButton_pressed()
		Constants.UNIT.FAX:
			buymenu.player = computer
			buymenu.grid_position = coordinates
			buymenu._on_FaxButton_pressed()
	buymenu.player = previous_player
	buymenu.grid_position = previous_grid_position

class baseSorter:
	static func sort_ascending(a, b):
		if a[0] < b[0]:
			return true
		return false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
