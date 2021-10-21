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
	JUNIOR,
	SENIOR,
	BAZOOKA_SENIOR,
	RECON
	#APC,
	#RECON,
	#AA,
	#TANK,
	#MDTANK,
	#ARTILLERY,
	#ROCKET,
	#TCOPTOR,
	#BCOPTOR,
	#FIGHTER,
	#BOMBER
}

#Unit Types
enum UNIT_TYPE{
	INFANTRY,
	VEHICLE,
	HELICOPTER,
	PLANE,
	SHIP
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

# Movement Types
enum MOVEMENT_TYPE{
	INFANTRY,
	MECH,
	TIRES,
	TREAD,
	AIR,
	SHIP,
	TRANS
}

# Attack Types
enum ATTACK_TYPE{
	DIRECT,
	INDIRECT,
	OTHER
}

# Infantry Movement Costs
enum INFANTRY_MOVEMENT{
	PLAINS = 1,
	FOREST = 1,
	MOUNTAIN = 2,
	ROAD = 1,
	RIVER = 2,
	SHOAL = 1
}

# Mech Movement Costs
enum MECH_MOVEMENT{
	PLAINS = 1,
	FOREST = 1,
	MOUNTAIN = 1,
	ROAD = 1,
	RIVER = 1,
	SHOAL = 1
}

# Tire Movement Costs
enum TIRE_MOVEMENT{
	PLAINS = 2,
	FOREST = 3,
	ROAD = 1,
	SHOAL = 1
}

# Tread Movement Costs
enum TREAD_MOVEMENT{
	PLAINS = 1,
	FOREST = 2,
	ROAD = 1,
	SHOAL = 1
}

# Air Movement Costs
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

var junior_dict = {
	UNIT.JUNIOR : 55, 
	UNIT.SENIOR : 45,
	UNIT.BAZOOKA_SENIOR : 45,
	UNIT.RECON : 12
	}

var senior_dict = {
	UNIT.JUNIOR : 65, 
	UNIT.SENIOR : 55,
	UNIT.BAZOOKA_SENIOR : 55,
	UNIT.RECON : 18
	}

# if Bazooka_senior doesn't have ammy, just use senior_dict
var bazooka_senior_dict = {
	UNIT.JUNIOR : 65, 
	UNIT.SENIOR : 55,
	UNIT.BAZOOKA_SENIOR : 55,
	UNIT.RECON : 85
	}
	
var damage_dict = {
	UNIT.JUNIOR : junior_dict,
	UNIT.SENIOR : senior_dict,
	UNIT.BAZOOKA_SENIOR : bazooka_senior_dict
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_damage(attacker: int, defender: int) -> int:
	return damage_dict[attacker][defender]
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

