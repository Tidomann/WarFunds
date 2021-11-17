extends Node2D

## Emitted when the commander's power changes
signal power_changed(playerOwner, power)

# Member Variables
# the current power meter value
export(float) var power = 0.0
# the maximum power meter value
export(float) var maxPower = 18000.0
# The name of the commander
export(String) var commanderName
# The name of the commander's power
export(String) var powerName
# referance to the player that is using this commander
export var player_path := @""
onready var playerOwner : Node2D = self.get_node(player_path)
export var stars_path := "res://assets/Sprites/UI/UICommander/PowerBar/2stars.png"
#onready var stars_overlay : Texture = stars_path
export(Constants.ARMY) var army_type := Constants.ARMY.BANKTANIA
var used_power := false
var power_used := 0
onready var commander_portrait = $commanderPortrait

# Called when the node enters the scene tree for the first time.
func _ready():
	var tmp = commander_portrait.texture.get_size()
	print(tmp.x)
	tmp.x = 128 / tmp.x
	tmp.y = 128 / tmp.y
	print(tmp)
	commander_portrait.scale = tmp
	pass # Replace with function body.

# increase the commanders current power meter by the passed parameter
func addPower(iPower : float) -> void:
	if(power + iPower > maxPower): #check for upper bounds
		power = maxPower
	elif(power + iPower < 0.0): #check for lower bounds
		power = 0.0
	else:
		power += iPower
	emit_signal("power_changed", playerOwner, power)

# decrease the commanders current power meter by the passed parameter
func removePower(iPower : float) -> void:
	if(power - iPower < 0.0): #check for lower bounds
		power = 0.0
	elif(power - iPower > maxPower): #check for upper bounds
		power = maxPower
	else:
		power -= iPower
	emit_signal("power_changed", playerOwner, power)

# set the power meter to it's maximum value
func setPowerFilled() -> void:
		power = maxPower
		emit_signal("power_changed", playerOwner, power)

# function that returns the current value of the commanders power
func currentPower() -> float:
	return power

# function that returns the current value of the commanders power as a
# percentage value (always rounds down)
func currentPowerPercent() -> int:
	return int(floor(power / maxPower * 100))

# function that checks to see if the current power is enough to use
# commanders power
func canUsePower() -> bool:
	if (power >= maxPower):
		return true
	return false

# accessor function to get the name of the commander
func getName() -> String:
	return commanderName

# accessor function to get the name of the commander's power
func getPowerName() -> String:
	return powerName

# accessor function to get the referance to the commander's player
func getOwner():
	return playerOwner

# mutator function to set the commander's player
func setOwner(newPlayer : Node2D):
	playerOwner = newPlayer

func strength_modifier(_attacker : Unit, _defender : Unit) -> float:
	var strength = 100.0
	if used_power:
		return strength*1.1
	return strength

func defense_modifier(_attacker : Unit, _defender : Unit) -> float:
	var defense = 100.0
	if used_power:
		return defense*1.1
	return defense

func use_power() -> void:
	if canUsePower():
		removePower(maxPower)
		if power_used <= 5:
			maxPower *= 1.2
			power_used += 1
		used_power = true
		#Do Power Stuff


func special_attack(_attacker, _defender) -> void:
	pass
			
func move_bonus() -> int:
	if used_power:
		return 2
	else:
		return 0

func luck_modifier() -> int:
	return 9

func bad_luck_modifier() -> int:
	return 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass