extends Node2D

# Member Variables
# the current power meter value
export(float) var power = 0.0
# the maximum power meter value
export(float) var maxPower = 5000.0
# The name of the commander
export(String) var commanderName
# The name of the commander's power
export(String) var powerName
# referance to the player that is using this commander
export var playerOwner = "res://Objects/BattleMap Objects/Player.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# increase the commanders current power meter by the passed parameter
func addPower(iPower : float) -> void:
	if(power + iPower > maxPower): #check for upper bounds
		power = maxPower
	elif(power + iPower < 0.0): #check for lower bounds
		power = 0.0
	else:
		power += iPower

# decrease the commanders current power meter by the passed parameter
func removePower(iPower : float) -> void:
	if(power - iPower < 0.0): #check for lower bounds
		power = 0.0
	elif(power - iPower > maxPower): #check for upper bounds
		power = maxPower
	else:
		power -= iPower

# set the power meter to it's maximum value
func setPowerFilled() -> void:
		power = maxPower

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
