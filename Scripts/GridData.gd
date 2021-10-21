extends Object

class_name GridData

# Object Variables
var coordinates:Vector2
var tileType:int
var unit:Path2D
var property:Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Unargumented constructor
func _init()->void:
	coordinates = Vector2(0,0)
	tileType = -1
	unit = null
	property = null

# accessor method for coordinates
func getCoordinates() -> Vector2:
	if coordinates != null:
		return coordinates
	print("null coordinates returned")
	return Vector2.ZERO

# accessor method for tileType
func getTileType() -> int:
	return tileType

# accessor method for unit
func getUnit() -> Path2D:
	if unit != null:
		return unit
	return null

func has_Unit() -> bool:
	if unit != null:
		return true
	return false

# accessor method for property
func getProperty() -> Node2D:
	if property != null:
		return property
	return null

# mutator method for coordinates (vector2)
func setCoordinatesV2(inCoords:Vector2) -> void:
	coordinates = inCoords

# mutator method for coordinates (x y values)
func setCoordinates(x:float, y:float) -> void:
	coordinates = Vector2(x, y)

# mutator method for tileType
func setTileType(inTile:int) -> void:
	tileType = inTile

# mutator method for unit
func setUnit(inUnit:Path2D) -> void:
	if inUnit == null:
		print("Null unit argument")
		return
	unit = inUnit

func clear_unit() -> void:
	unit = null

# mutator method for property
func setProperty(inProperty:Node2D) -> void:
	if inProperty == null:
		print("Null Property argument")
		return
	property = inProperty

# TRACERCODE FUNCTION TO MAKE SURE GRID WORKING LOL
func print() -> String:
	var out = String(coordinates)
	out += " Tiletype:" + String(tileType)
	if unit != null:
		out += " Unit: Exists"
	else:
		out += " Unit no existo"
	if property != null:
		out += " Property: Exists"
	return out
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
