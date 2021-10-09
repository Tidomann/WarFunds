extends Node2D

var tileSet = preload("res://assets/Sprites/Tile/dev_tileset.tres")

class_name Constants
#Map Constants
enum TILE{
	PLAINS = 0,
	FOREST = 1,
	MOUNTAIN = 2,
	SEA = 3,
	ROAD = 4,
	RIVER = 5,
	BEACH = 6,
	SHOAL = 7,
}


#Unit Constants
enum UNIT{
	INFANTRY,
	MECH,
	APC,
	RECON,
	AA,
	TANK,
	MDTANK,
	ARTILLERY,
	ROCKET,
	
	TCOPTOR,
	BCOPTOR,
	FIGHTER,
	BOMBER
}

enum PROPERTY{
	HQ
	AIRPORT
	BASE
	CITY
	PORT
	COMM_TOWER
	LAB
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
