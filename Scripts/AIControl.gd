extends Node2D


var dijkstra_map: DijkstraMap = DijkstraMap.new()
export var gamegrid: Resource
var battlemap
var devtiles
var turn_queue
var soundmanager
var human_player
var gameboard
onready var timer = $Timer

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func take_computer_turn(computer : Node2D) -> void:
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
	if not direct.empty():
		yield(direct_actions(direct), "completed")
	if not mech.empty():
		yield(direct_actions(mech), "completed")
	if not infantry.empty():
		yield(infantry_actions(infantry), "completed")
		

func init(inbattlemap : Node2D) -> void:
	battlemap = inbattlemap
	turn_queue = battlemap.get_node("TurnQueue")
	soundmanager = battlemap.get_node("GameBoard/SoundManager")
	human_player = battlemap.get_node("TurnQueue/Human")
	gameboard = battlemap.get_node("GameBoard")
	devtiles = gamegrid.devtiles
	var index = 0
	for cell in gamegrid.array:
		if cell != null:
			if cell.property != null:
				dijkstra_map.add_point(index, Constants.TILE.PROPERTY)
			else:
				dijkstra_map.add_point(index, cell.tileType)
		index += 1
	index = 0
	for cell in devtiles.get_used_cells():
		for direction in DIRECTIONS:
			var adjacent_coordinate: Vector2 = cell + direction
			if not gamegrid.is_gridcoordinate_within_map(adjacent_coordinate):
				continue
			if devtiles.get_cellv(adjacent_coordinate) != -1 && not dijkstra_map.has_connection(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate)):
				dijkstra_map.connect_points(gamegrid.as_index(cell), gamegrid.as_index(adjacent_coordinate), 1.0, true)

func recalculate_map(unit : Unit, cell : Vector2) -> void:
	var movement_type = unit.movement_type
	var cost_dict
	match movement_type:
		Constants.MOVEMENT_TYPE.INFANTRY:
			cost_dict = { Constants.TILE.PLAINS: 1.0, Constants.TILE.FOREST: 1.0, Constants.TILE.MOUNTAIN: 2.0, Constants.TILE.ROAD: 1.0, Constants.TILE.RIVER: 2.0, Constants.TILE.SHOAL: 1.0, Constants.TILE.PROPERTY: 1.0, }
		Constants.MOVEMENT_TYPE.MECH:
			cost_dict = { Constants.TILE.PLAINS: 1.0, Constants.TILE.FOREST: 1.0, Constants.TILE.MOUNTAIN: 1.0, Constants.TILE.ROAD: 1.0, Constants.TILE.RIVER: 1.0, Constants.TILE.SHOAL: 1.0, Constants.TILE.PROPERTY: 1.0, }
		Constants.MOVEMENT_TYPE.TIRES:
			cost_dict = { Constants.TILE.PLAINS: 2.0, Constants.TILE.FOREST: 3.0, Constants.TILE.ROAD: 1.0, Constants.TILE.SHOAL: 1.0, Constants.TILE.PROPERTY: 1.0, }
		Constants.MOVEMENT_TYPE.TREAD:
			cost_dict = { Constants.TILE.PLAINS: 1.0, Constants.TILE.FOREST: 2.0, Constants.TILE.ROAD: 1.0, Constants.TILE.SHOAL: 1.0, Constants.TILE.PROPERTY: 1.0, }
		Constants.MOVEMENT_TYPE.AIR:
			cost_dict = { Constants.TILE.PLAINS: 1.0, Constants.TILE.FOREST: 1.0, Constants.TILE.MOUNTAIN: 1.0, Constants.TILE.SEA: 1.0, Constants.TILE.ROAD: 1.0, Constants.TILE.RIVER: 1.0, Constants.TILE.SHOAL: 1.0, Constants.TILE.REEF: 1.0, Constants.TILE.PROPERTY: 1.0, }
		Constants.MOVEMENT_TYPE.SHIP:
			# not yet implemented
			pass
	var movement_range = float(unit.move_range + unit.playerOwner.commander.move_bonus())
	var optional_params = {
		"input_is_destination": true,
		"terrain_weights": cost_dict,
		"maximum_cost": movement_range,
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
		"terrain_weights": cost_dict,
	}
	dijkstra_map.recalculate(array, optional_params)

func best_attack_path_direct(attacker : Unit) -> PoolVector2Array:
	recalculate_map(attacker, attacker.cell)
	print(dijkstra_map.get_cost_map())
	var move_bonus = attacker.playerOwner.commander.move_bonus()
	var dijkstra_tiles = dijkstra_map.get_all_points_with_cost_between(0.0, float(attacker.move_range + move_bonus))
	var test_array : Array = []
	for index in dijkstra_tiles:
		test_array.append(gamegrid.array[index].coordinates)
	battlemap._unit_overlay.draw(test_array)
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
			dijkstra_map.disable_point(gamegrid.as_index(unit.cell))
	recalculate_map(attacker, attacker.cell)
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
			dijkstra_map.enable_point(index)
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
				recalculate_to_targets_map(attacker.movement_type,long_distance_coordinates)
				# Set starting index
				destination_path.append(attacker.cell)
				var next_index = gamegrid.as_index(attacker.cell)
				var move_distance = dijkstra_map.get_cost_at_point(next_index)
				var move_bonus = attacker.playerOwner.commander.move_bonus()
				while move_distance - dijkstra_map.get_cost_at_point(next_index) < (attacker.move_range + move_bonus):
					next_index = dijkstra_map.get_direction_at_point(next_index)
					destination_path.append(gamegrid.array[next_index].coordinates)
				# if the final destination coordinate is blocked
				if gamegrid.array[next_index].getUnit() != null:
					dijkstra_map.disable_point(next_index)
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
				print(cell)
				property_coordinates.append(gamegrid.as_index(cell))
		if not property_coordinates.empty():
			var final_move_blocked = true
			while final_move_blocked:
				destination_path = []
				recalculate_to_targets_map(attacker.movement_type, property_coordinates)
				print(dijkstra_map.get_direction_map())
				# Set starting index
				destination_path.append(attacker.cell)
				var next_index = gamegrid.as_index(attacker.cell)
				var move_distance = dijkstra_map.get_cost_at_point(next_index)
				var move_bonus = attacker.playerOwner.commander.move_bonus()
				while move_distance - dijkstra_map.get_cost_at_point(next_index) < (attacker.move_range + move_bonus):
					next_index = dijkstra_map.get_direction_at_point(next_index)
					destination_path.append(gamegrid.array[next_index].coordinates)
				# if the final destination coordinate is blocked
				if gamegrid.array[next_index].getUnit() != null:
					dijkstra_map.disable_point(next_index)
				else:
					final_move_blocked = false
			reactivate_all_points()
			#battlemap._unit_overlay.draw(destination_path)
			return destination_path
		else:
			reactivate_all_points()
			#battlemap._unit_overlay.draw(destination_path)
			return destination_path

func defensive_direct(attacker: Unit) -> PoolVector2Array:
	recalculate_map(attacker, attacker.cell)
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
	# Disable Movement through enemies
	for unit in battlemap._units_node.get_children():
		# Attacker cannot travel on top of enemy
		if attacker.playerOwner.team != unit.playerOwner.team:
			dijkstra_map.disable_point(gamegrid.as_index(unit.cell))
	recalculate_map(attacker, attacker.cell)
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
			if not unit.defensive_ai:
				var path = best_attack_path_direct(unit)
				var old_position = unit.cell
				move_computer_unit(unit, path)
				if path.size() > 1:
					yield(unit, "walk_finished")
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
				#print(unit.cell)
				var path = defensive_direct(unit)
				var old_position = unit.cell
				move_computer_unit(unit, path)
				if path.size() > 1:
					yield(unit, "walk_finished")
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

func infantry_actions(infantry : Array) -> void:
	for unit in infantry:
		var path = defensive_direct(unit)
		var old_position = unit.cell
		move_computer_unit(unit,path)
		if path.size() > 1:
			yield(unit, "walk_finished")
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
			path = no_targets_direct_path(unit)
			move_computer_unit(unit,path)
			if path.size() > 1:
				yield(unit, "walk_finished")
			var new_position = unit.cell
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
			timer.set_wait_time(2)
		timer.set_one_shot(true)
		timer.start()
		yield(timer, "timeout")


func move_computer_unit(unit : Unit, path : PoolVector2Array) -> void:
	if path.size() > 1:
		unit.walk_along(path)
		gamegrid.array[gamegrid.as_index(path[0])].unit = null
		gamegrid.array[gamegrid.as_index(path[path.size()-1])].unit = unit
		unit.cell = path[path.size()-1]

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
	timer.set_wait_time(1.0)
	timer.set_one_shot(true)
	timer.start()
	yield(timer, "timeout")
	gamegrid.unit_combat(attacker, defender)
	self.visible = false
	if attacker.turnReady:
		attacker.flip_turnReady()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass