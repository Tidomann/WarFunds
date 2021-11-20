extends Node


var path = "res://Objects/Commanders/William.tscn"
var unlockedLeaders = [true,true,true,false,false,false,false,false]
var unlockedLevels = [true,false,false,false,false,false,false,false]

var leaders = [
	"res://assets/Sprites/DepartmentLeaders/Kronk/Konkneutral.png",
	"res://assets/Sprites/DepartmentLeaders/Redline/Redlineneutral.png",	
	"res://assets/Sprites/DepartmentLeaders/William/Williamneutral.png"
]

var leaderPath = [
	"res://Objects/Commanders/Kronk.tscn",
	"res://Objects/Commanders/RedLine.tscn",
	"res://Objects/Commanders/William.tscn"
]

var leadersDesc = [
	"Kronk: Boi",
	"RedLine: ioB",
	"William: oBi"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
