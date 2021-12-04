extends Node2D

## Emitted when the commander's power changes
signal power_changed(playerOwner, power)

# Member Variables
# the current power meter value
export(float) var power = 0.0
# the maximum power meter value
export(float) var maxPower = 36000.0
# The name of the commander
export(String) var commanderName
# The name of the commander's power
export(String) var powerName
# referance to the player that is using this commander
export var player_path := @""
var playerOwner : Node2D
export var stars_path := "res://assets/Sprites/UI/UICommander/PowerBar/4stars.png"
#onready var stars_overlay : Texture = stars_path
export(Constants.ARMY) var army_type := Constants.ARMY.COSC
var used_power := false
var power_used := 0
onready var commander_portrait = $commanderPortrait
onready var power_activated = get_parent().get_parent().get_parent().get_node("CanvasLayer").get_node("PowerActivated")

# Called when the node enters the scene tree for the first time.
func _ready():
	var tmp = commander_portrait.texture.get_size()
	tmp.x = 128 / tmp.x
	tmp.y = 128 / tmp.y
	commander_portrait.scale = tmp
	if not player_path.is_empty():
		playerOwner = self.get_node(player_path)

# increase the commanders current power meter by the passed parameter
func addPower(iPower : float) -> void:
	if(power + iPower > maxPower): #check for upper bounds
		power = maxPower
	elif(power + iPower < 0.0): #check for lower bounds
		power = 0.0
	else:
		power += iPower
	emit_signal("power_changed", playerOwner, power, maxPower)

# decrease the commanders current power meter by the passed parameter
func removePower(iPower : float) -> void:
	if(power - iPower < 0.0): #check for lower bounds
		power = 0.0
	elif(power - iPower > maxPower): #check for upper bounds
		power = maxPower
	else:
		power -= iPower
	emit_signal("power_changed", playerOwner, power, maxPower)

# set the power meter to it's maximum value
func setPowerFilled() -> void:
		power = maxPower
		emit_signal("power_changed", playerOwner, power, maxPower)

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
		var grid_referance = playerOwner.get_parent().gamegrid
		removePower(maxPower)
		power_activated.power_activated(commander_portrait.texture, powerName)
		if power_used <= 5:
			maxPower *= 1.2
			power_used += 1
		used_power = true
		#Do Power Stuff
		for game_data in grid_referance.array:
			# If there is a unit at this location
			if game_data.unit != null:
				# If the unit belongs to an ally
				if game_data.unit.playerOwner.team == playerOwner.team:
					var t = Timer.new()
					t.set_wait_time(0.15)
					t.set_one_shot(true)
					self.add_child(t)
					t.start()
					yield(t, "timeout")
					t.queue_free()
					# Heal 20 damage (Clarissa gets a bonus to this healing)
					game_data.unit.power_animation(self)
					game_data.unit.get_healing(20)
		emit_signal("power_changed", playerOwner, power, maxPower)


func special_attack(_attacker, _defender, damage_result) -> int:
	if used_power:
		pass
	return damage_result

func move_bonus() -> int:
	return 0

func luck_modifier() -> int:
	return 9

func bad_luck_modifier() -> int:
	return 0

func get_unit_cost_multiplier() -> float:
	return 1.0

func get_unit_cost(unit: Unit) -> int:
	return int(unit.cost*get_unit_cost_multiplier())

# Clarissa's heal command is 50% cheaper (normally 2x cost, now 1x cost)
func get_heal_discount() -> float:
	var heal_discount = 0.75
	return heal_discount

func get_heal_bonus() -> int:
	# Value healed is in % of unit life
	var heal_bonus = 10
	return heal_bonus

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
