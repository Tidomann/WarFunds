## Represents a unit on the game board.
## The board manages its position inside the game grid.
## The unit itself holds stats and a visual representation that moves smoothly in the game world.
tool
class_name Unit
extends Path2D

## Emitted when the unit reached the end of a path along which it was walking.
signal walk_finished


export var player_path := @""
var playerOwner : Node2D
## Shared resource of type Grid, used to calculate map coordinates.
export var grid: Resource
## Coordinates of the current cell the unit moved to.
export var cell : Vector2
## Referance to the unit constant
export(Constants.UNIT) var unit_referance
## The Units Health
export var health := 100
## Referance to the unit type
export(Constants.UNIT_TYPE) var unit_type
## Cost of the unit
export var cost := 1000
## Type of movement for the unit
export(Constants.MOVEMENT_TYPE) var movement_type
## Distance to which the unit can walk in cells.
export var move_range := 3
## Type of attack for the unit
export(Constants.ATTACK_TYPE) var attack_type
## The Units Ammo
export var ammo : int
## The unit's combat attack range.
export var atk_range := 1
## The unit's combat attack minimum range.
export var min_atk_range := 0
## The unit's move speed when it's moving along a path.
export var move_speed := 100.0
## The unit's combat attack range.
export var vision_range := 2
## Texture representing the unit.
export var skin: Texture setget set_skin
## Offset to apply to the `skin` sprite in pixels.
export var skin_offset := Vector2.ZERO setget set_skin_offset
## Variable if there is an army specific sprite
export var army_sprite : bool
export var defensive_ai : bool
export var ai_healing: bool

export(bool) var turnReady = true

## Toggles the "selected" animation on the unit.
var is_selected := false setget set_is_selected

var _is_walking := false setget _set_is_walking

onready var _sprite: Sprite = $PathFollow2D/Sprite
onready var _hp : Sprite = $PathFollow2D/Health
onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _path_follow: PathFollow2D = $PathFollow2D
onready var _army_colour: AnimationPlayer = $ArmyColour


func _ready() -> void:
	set_process(false)
	# We create the curve resource here because creating it in the editor prevents us from
	# moving the unit.
	if not Engine.editor_hint:
		curve = Curve2D.new()
	if not player_path.is_empty():
		playerOwner = self.get_node(player_path)


func update_position() -> void:
	position = grid.calculate_map_position(cell)

func set_flip() -> void:
	# Set the facing of the unit according to the player
	if playerOwner.facing == "Left":
		_sprite.set_flip_h(true)


func _process(delta: float) -> void:
	_path_follow.offset += move_speed * delta

	if _path_follow.offset >= curve.get_baked_length():
		self._is_walking = false
		_path_follow.offset = 0
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		emit_signal("walk_finished")


## Starts walking along the `path`.
## `path` is an array of grid coordinates that the function converts to map coordinates.
func walk_along(path: PoolVector2Array) -> void:
	if path.empty():
		return
	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	self._is_walking = true


func set_cell(value: Vector2) -> void:
	cell = value

func get_cell() -> Vector2:
	return cell


func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		_anim_player.play("selected")
	else:
		_anim_player.play("idle")


func set_skin(value: Texture) -> void:
	skin = value
	if not _sprite:
		yield(self, "ready")
	_sprite.texture = value


func set_skin_offset(value: Vector2) -> void:
	skin_offset = value
	if not _sprite:
		yield(self, "ready")
	_sprite.position = value


func _set_is_walking(value: bool) -> void:
	_is_walking = value
	set_process(_is_walking)

func getPlayerOwner() -> Node2D:
	return playerOwner

func is_turnReady() -> bool:
	return turnReady

func flip_turnReady() -> void:
	turnReady = !turnReady
	if not turnReady:
		_sprite.modulate = Color(0.44, 0.44, 0.44)
		_hp.modulate = Color(0.44, 0.44, 0.44)
	else:
		_sprite.modulate = Color(1, 1, 1)
		_hp.modulate = Color(1, 1, 1)

func get_unit_team() -> int:
	return playerOwner.team

func get_commander() -> Node2D:
	return playerOwner.commander

func take_damage(damage_recieved : int) -> int:
	var damage
	if damage_recieved > health:
		damage = health
		health = 0
		update_health()
		damage = ceil(damage * 0.1)
	else:
		damage = damage_recieved
		health -= damage_recieved
		update_health()
		damage = floor(damage*0.1)
	return int(damage)

func heal_differance(healing_recieved : int) -> int:
	var amount_healed
	if healing_recieved + health > 100:
		amount_healed = 100 - health
		update_health()
		amount_healed = floor(amount_healed*0.1)
	else:
		amount_healed = ceil(healing_recieved*0.1)
		update_health()
	return amount_healed
	
func get_healing(healing_recieved :int) -> int:
	var amount_healed
	if healing_recieved + health > 100:
		amount_healed = 100 - health
		health = 100
		update_health()
		ai_healing = false
		amount_healed = floor(amount_healed*0.1)
	else:
		amount_healed = ceil(healing_recieved*0.1)
		health += healing_recieved	
		update_health()
	return amount_healed*0.1*cost

func use_ammo(_defender : Unit) -> bool:
	return false

func is_dead() -> bool:
	return health <= 0

func update_health() -> void:
	if health < 91 && health > 0:
		_hp.visible = true
		_hp.frame = int((health-1)*0.1)
	else:
		_hp.visible = false

func get_move_range() -> int:
	return move_range + playerOwner.commander.move_bonus()

func army_color_set() -> void:
	if army_sprite:
		match playerOwner.commander.army_type:
			Constants.ARMY.ENGINEERING:
				match playerOwner.player_colour:
					Constants.COLOUR.RED:
						_army_colour.play("eRed")
					Constants.COLOUR.BLUE:
						_army_colour.play("eBlue")
					Constants.COLOUR.GREEN:
						_army_colour.play("eGreen")
					Constants.COLOUR.YELLOW:
						_army_colour.play("eYellow")
					Constants.COLOUR.CYAN:
						_army_colour.play("eCyan")
					Constants.COLOUR.PURPLE:
						_army_colour.play("ePurple")
			Constants.ARMY.COSC:
				match playerOwner.player_colour:
					Constants.COLOUR.RED:
						_army_colour.play("cRed")
					Constants.COLOUR.BLUE:
						_army_colour.play("cBlue")
					Constants.COLOUR.GREEN:
						_army_colour.play("cGreen")
					Constants.COLOUR.YELLOW:
						_army_colour.play("cYellow")
					Constants.COLOUR.CYAN:
						_army_colour.play("cCyan")
					Constants.COLOUR.PURPLE:
						_army_colour.play("cPurple")
			Constants.ARMY.BIOLOGY:
				match playerOwner.player_colour:
					Constants.COLOUR.RED:
						_army_colour.play("sRed")
					Constants.COLOUR.BLUE:
						_army_colour.play("sBlue")
					Constants.COLOUR.GREEN:
						_army_colour.play("sGreen")
					Constants.COLOUR.YELLOW:
						_army_colour.play("sYellow")
					Constants.COLOUR.CYAN:
						_army_colour.play("sCyan")
					Constants.COLOUR.PURPLE:
						_army_colour.play("sPurple")
			Constants.ARMY.FINANCE:
				match playerOwner.player_colour:
					Constants.COLOUR.RED:
						_army_colour.play("fRed")
					Constants.COLOUR.BLUE:
						_army_colour.play("fBlue")
					Constants.COLOUR.GREEN:
						_army_colour.play("fGreen")
					Constants.COLOUR.YELLOW:
						_army_colour.play("fYellow")
					Constants.COLOUR.CYAN:
						_army_colour.play("fCyan")
					Constants.COLOUR.PURPLE:
						_army_colour.play("fPurple")
			Constants.ARMY.NURSING:
				match playerOwner.player_colour:
					Constants.COLOUR.RED:
						_army_colour.play("nRed")
					Constants.COLOUR.BLUE:
						_army_colour.play("nBlue")
					Constants.COLOUR.GREEN:
						_army_colour.play("nGreen")
					Constants.COLOUR.YELLOW:
						_army_colour.play("nYellow")
					Constants.COLOUR.CYAN:
						_army_colour.play("nCyan")
					Constants.COLOUR.PURPLE:
						_army_colour.play("nPurple")
			Constants.ARMY.BANKTANIA:
				match playerOwner.player_colour:
					Constants.COLOUR.RED:
						_army_colour.play("bRed")
					Constants.COLOUR.BLUE:
						_army_colour.play("bBlue")
					Constants.COLOUR.GREEN:
						_army_colour.play("bGreen")
					Constants.COLOUR.YELLOW:
						_army_colour.play("bYellow")
					Constants.COLOUR.CYAN:
						_army_colour.play("bCyan")
					Constants.COLOUR.PURPLE:
						_army_colour.play("bPurple")
	else:
		match playerOwner.player_colour:
			Constants.COLOUR.RED:
				_army_colour.play("Red")
			Constants.COLOUR.BLUE:
				_army_colour.play("Blue")
			Constants.COLOUR.GREEN:
				_army_colour.play("Green")
			Constants.COLOUR.YELLOW:
				_army_colour.play("Yellow")
			Constants.COLOUR.CYAN:
				_army_colour.play("Cyan")
			Constants.COLOUR.PURPLE:
				_army_colour.play("Purple")
