class_name UnitPath
extends TileMap

export var gamegrid : Resource

# This variable holds a reference to a PathFinder object. We'll create a new one every time the 
# player select a unit.
var pathfinder: PathFinder
var valid_cells
# This property caches a path found by the _pathfinder above.
# We cache the path so we can reuse it from the game board. If the player decides to confirm unit
# movement with the cursor, we can pass the path to the unit's walk_along() function.
var current_path := PoolVector2Array()

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Creates a new PathFinder that uses the AStar algorithm we use to find a path between two cells 
# among the `walkable_cells`.
# We'll call this function every time the player selects a unit.
func initialize(walkable_cells: Array, unit : Unit) -> void:
	pathfinder = PathFinder.new(gamegrid, walkable_cells)
	valid_cells = walkable_cells
	current_path.append(unit.get_cell())

# Finds and draws the path between `cell_start` and `cell_end`.
func draw(unit: Unit, cell_end: Vector2) -> void:
	if not valid_cells.has(cell_end):
		return
	if current_path.empty():
		redraw(unit.get_cell(), cell_end)
		return
	# if cell-end is not a neighbor the the last thing in the array use pathfinder
	if current_path[0] != unit.get_cell():
		redraw(unit.get_cell(), cell_end)
		return
	var is_neighbour = false
	for direction in DIRECTIONS:
		if direction + cell_end == current_path[current_path.size()-1]:
			is_neighbour = true
	if not is_neighbour:
		redraw(unit.get_cell(), cell_end)
		return
	# if cell_end is not a valid move use pathfinder
	if not gamegrid.is_valid_move(unit.movement_type, gamegrid.get_GridData(gamegrid.as_index(cell_end)).getTileType()):
			redraw(unit.get_cell(), cell_end)
			return
	# if the path already contains the cell_end use pathfinder
	for cell in current_path:
		if cell == cell_end:
			redraw(unit.get_cell(), cell_end)
			return
	#if the cost of the current path exceeds the move range use pathfinder
	var move_cost = -(gamegrid.get_movecost(unit.movement_type, gamegrid.get_GridData(gamegrid.as_index(unit.get_cell())).getTileType()))
	for cell in current_path:
		var tilecost = gamegrid.get_movecost(unit.movement_type, gamegrid.get_GridData(gamegrid.as_index(cell)).getTileType())
		#current path exceeds the move range use pathfinder
		if move_cost + tilecost > unit.move_range:
			redraw(unit.get_cell(), cell_end)
			return
		move_cost += tilecost
	# if the cost of the current path plus the cost of the final cell exceed the move range
	# use pathfinder
	if (move_cost + gamegrid.get_movecost(unit.movement_type, gamegrid.get_GridData(gamegrid.as_index(cell_end)).getTileType())
	> unit.move_range):
		redraw(unit.get_cell(), cell_end)
		return

	current_path.append(cell_end)
	clear()
	# And we draw a tile for every cell in the path.
	for cell in current_path:
		set_cellv(cell, 0)

	# The function below updates the auto-tiling. Without it, you wouldn't get the nice path with curves
	# and the arrows on either end.
	update_bitmask_region()
# Finds and draws the path between `cell_start` and `cell_end`.
func redraw(cell_start: Vector2, cell_end: Vector2) -> void:
	# We first clear any tiles on the tilemap, then let the Astar2D (PathFinder) find the
	# path for us.
	clear()
	current_path = pathfinder.calculate_point_path(cell_start, cell_end)
	# And we draw a tile for every cell in the path.
	for cell in current_path:
		set_cellv(cell, 0)
	# The function below updates the auto-tiling. Without it, you wouldn't get the nice path with curves
	# and the arrows on either end.
	update_bitmask_region()

# Stops drawing, clearing the drawn path and the `_pathfinder`.
func stop() -> void:
	pathfinder = null
	clear()

func clear_path() -> void:
	current_path = PoolVector2Array()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
