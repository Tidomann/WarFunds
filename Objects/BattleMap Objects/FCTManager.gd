extends Panel

var FCT = preload("res://Objects/BattleMap Objects/DamageDisplay.tscn")
onready var fct = $FCT
onready var fct2 = $FCT2

func show_value(attacker, dmgdone, target, dmgtaken):
	var colour1 = Constants.get_colour(attacker.playerOwner.player_colour)
	var colour2 = Constants.get_colour(target.playerOwner.player_colour)
	self.visible = true
	fct.visible = true
	fct2.visible = true
	fct.bbcode_text = ""
	fct2.bbcode_text = ""
	fct.push_color(colour1)
	fct.add_text(dmgdone)
	fct.pop()
	fct2.push_color(colour2)
	fct2.add_text(dmgtaken)
	fct2.pop()

	if dmgtaken == "0":
		fct2.visible = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
