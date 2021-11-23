extends Node2D

#Army Sprite Constants
enum ARMY{
	ENGINEERING = 0,
	COSC = 1,
	BIOLOGY = 2,
	FINANCE = 3,
	NURSING = 4,
	BANKTANIA = 5
}

enum COLOUR{
	RED = 0,
	BLUE = 1,
	GREEN = 2,
	YELLOW = 3,
	CYAN = 4,
	PURPLE = 5
}


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

# Terrain Defense Bonus
var TILE_DEFENSE = {
	TILE.PLAINS : 1,
	TILE.FOREST : 2,
	TILE.MOUNTAIN : 3,
	TILE.SEA : 0,
	TILE.ROAD : 0,
	TILE.RIVER : 0,
	TILE.SHOAL : 0,
	TILE.REEF : 1
	}

#Unit Constants
enum UNIT{
	JUNIOR,
	SENIOR,
	BAZOOKA_SENIOR,
	SCANNER,
	TOWER,
	PRINTER,
	STAPLER,
	#APC,
	#RECON,
	#AA,
	#TANK
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
	HQ = 0,
	CITY = 1,
	BASE = 2,
	AIRPORT = 3,
	PORT = 4,
	TOWER = 5
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

var movement_dict ={
	
}

var junior_dict = {
	UNIT.JUNIOR : 55, 
	UNIT.SENIOR : 45,
	UNIT.BAZOOKA_SENIOR : 45,
	UNIT.SCANNER : 12,
	UNIT.TOWER : 10,
	UNIT.PRINTER : 5,
	UNIT.STAPLER : 15
	}

var senior_dict = {
	UNIT.JUNIOR : 65, 
	UNIT.SENIOR : 55,
	UNIT.BAZOOKA_SENIOR : 55,
	UNIT.SCANNER : 18,
	UNIT.TOWER : 10,
	UNIT.PRINTER : 6,
	UNIT.STAPLER : 32
	}

# if Bazooka_senior doesn't have ammo, just use senior_dict
var bazooka_senior_dict = {
	UNIT.JUNIOR : 65, 
	UNIT.SENIOR : 55,
	UNIT.BAZOOKA_SENIOR : 55,
	UNIT.SCANNER : 85,
	UNIT.TOWER : 10,
	UNIT.PRINTER : 55,
	UNIT.STAPLER : 70
	}

# if Bazooka_senior doesn't have ammo, just use senior_dict
var scanner_dict = {
	UNIT.JUNIOR : 70, 
	UNIT.SENIOR : 65,
	UNIT.BAZOOKA_SENIOR : 65,
	UNIT.SCANNER : 35,
	UNIT.TOWER : 10,
	UNIT.PRINTER : 6,
	UNIT.STAPLER : 45
	}
	
var printer_dict = {
	UNIT.JUNIOR : 75, 
	UNIT.SENIOR : 50,
	UNIT.BAZOOKA_SENIOR : 50,
	UNIT.SCANNER : 85,
	UNIT.TOWER : 10,
	UNIT.PRINTER : 55,
	UNIT.STAPLER : 70
}
var stapler_dict = {
	UNIT.JUNIOR : 90, 
	UNIT.SENIOR : 85,
	UNIT.BAZOOKA_SENIOR : 85,
	UNIT.SCANNER : 80,
	UNIT.TOWER : 10,
	UNIT.PRINTER : 70,
	UNIT.STAPLER : 75
}

var damage_dict = {
	UNIT.JUNIOR : junior_dict,
	UNIT.SENIOR : senior_dict,
	UNIT.BAZOOKA_SENIOR : bazooka_senior_dict,
	UNIT.SCANNER : scanner_dict,
	UNIT.PRINTER : printer_dict,
	UNIT.STAPLER : stapler_dict
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_damage(attacker: int, defender: int) -> int:
	return damage_dict[attacker][defender]

func get_colour(colour : int) -> Color:
	match colour:
		Constants.COLOUR.RED:
			return Color("aa003f")
		Constants.COLOUR.BLUE:
			return Color("335eb0")
		Constants.COLOUR.GREEN:
			return Color("30f830")
		Constants.COLOUR.YELLOW:
			return Color("d39c36")
		Constants.COLOUR.CYAN:
			return Color("20918b")
		Constants.COLOUR.PURPLE:
			return Color("46324c")
	return Color( 1, 1, 1, 1 )

#func get_terrain_bonus
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

