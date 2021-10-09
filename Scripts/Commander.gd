extends Node2D

export(float) var power = 0.0

export(float) var maxPower = 5000.0

export(String) var commanderName

export(String) var powerName

export var playerOwner = "res://Objects/BattleMap Objects/Player.tscn"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func addPower(iPower : float) -> void:
	if(power + iPower > maxPower):
		power = maxPower
	else:
		power += iPower

func removePower(iPower : float) -> void:
	if(power - iPower < 0.0):
		power = 0.0
	else:
		power -= iPower

func setPowerFilled() -> void:
		power = maxPower

func currentPower() -> float:
	return power

func currentPowerPercent() -> float:
	return floor(power / maxPower * 100)

func canUsePower() -> bool:
	if (power >= maxPower):
		return true
	return false

func getName() -> String:
	return commanderName

func getPowerName() -> String:
	return powerName

func getOwner():
	return playerOwner

func setOwner(newPlayer : Node2D):
	playerOwner = newPlayer
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
