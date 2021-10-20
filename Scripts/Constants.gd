extends Node2D

#Map Constants
enum TILE{
	PLAINS = 0,
	FOREST = 1,
	MOUNTAIN = 2,
	SEA = 3,
	ROAD = 4,
	RIVER = 5,
	SHOAL = 6,
	REEF = 7
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
	HQ,
	AIRPORT,
	BASE,
	CITY,
	PORT,
	COMM_TOWER,
	LAB
}

enum MOVEMENT_TYPE{
	INFANTRY,
	MECH,
	TIRES,
	TREAD,
	AIR,
	SHIP,
	TRANS
}

enum ATTACK_TYPE{
	DIRECT,
	INDIRECT,
	OTHER
}

enum INFANTRY_MOVEMENT{
	PLAINS = 1,
	FOREST = 1,
	MOUNTAIN = 2,
	ROAD = 1,
	RIVER = 2,
	SHOAL = 1
}

enum MECH_MOVEMENT{
	PLAINS = 1,
	FOREST = 1,
	MOUNTAIN = 1,
	ROAD = 1,
	RIVER = 1,
	SHOAL = 1
}

enum TIRE_MOVEMENT{
	PLAINS = 2,
	FOREST = 3,
	ROAD = 1,
	SHOAL = 1
}

enum TREAD_MOVEMENT{
	PLAINS = 1,
	FOREST = 2,
	ROAD = 1,
	SHOAL = 1
}

enum AIR_MOVEMENT{
	PLAINS = 1,
	FOREST = 1,
	MOUNTAIN = 1,
	SEA = 1,
	ROAD = 1,
	RIVER = 1,
	SHOAL = 1,
	REEF = 1
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
