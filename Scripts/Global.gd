extends Node

# Selected Leader
var path = "res://Objects/Commanders/William.tscn"

# Currently Unlocked Leaders and Levels
var unlockedLeaders = [true,true,true,false,false,false,false,false]
var unlockedLevels = [true,false,false,false,false,false,false,false]

# Leader Images
var leaders = [
	"res://assets/Sprites/DepartmentLeaders/Kronk/KronkNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Redline/RedlineNeutral.png",	
	"res://assets/Sprites/DepartmentLeaders/William/WilliamNeutral.png"
]

# Path to leader scene
var leaderPath = [
	"res://Objects/Commanders/Kronk.tscn",
	"res://Objects/Commanders/RedLine.tscn",
	"res://Objects/Commanders/William.tscn"
]

# Leader abilities and information
var leadersDesc = [
	"Kronk: Boi",
	"RedLine: ioB",
	"William: oBi"
]

# Levels
var levels = [
	"res://Scenes/BattleMap.tscn"
]
