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

func load_data():
	# TileType Load
	for cell in devtiles.get_used_cells():
		var array_index = as_index(cell)
		array[array_index] = GridData.new()
		array[array_index].setTileType(devtiles.get_cellv(cell))
		array[array_index].setCoordinatesV2(cell)
	# Unit Load
	for unit in gameBoard.get_children():
		if unit.get_class() != "Path2D":
			continue
		var tempIndex = as_index(unit.get_cell())
		if array[tempIndex].getUnit() == null:
			array[tempIndex].setUnit(unit)
	# TODO: Property Load

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

func is_occupied(cell: Vector2) -> bool:
	return true if array[as_index(cell)].getUnit() != null else false
