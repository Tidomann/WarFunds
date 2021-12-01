extends Node

# Selected Leader
var path = "res://Objects/Commanders/William.tscn"
var intro_dialogue = "res://Dialog/GameIntro.json"
var next_level = "res://Scenes/Select.tscn"
var player_colour = Constants.COLOUR.BLUE

# Currently Unlocked Leaders and Levels
var unlockedLeaders = [true,false,false,false,false,false,false,false]
var unlockedLevels = [true,false,false,false,false,false,false,false]
var unlockedColours = [false,true,false,false,false,false]

# Leader Images
var leaders = [
	"res://assets/Sprites/DepartmentLeaders/William/WilliamNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Sally/SallyNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Redline/RedlineNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Kronk/KronkNeutral.png",
]

# Path to leader scene
var leaderPath = [
	"res://Objects/Commanders/William.tscn",
	"res://Objects/Commanders/Sally.tscn",
	"res://Objects/Commanders/RedLine.tscn",
	"res://Objects/Commanders/Kronk.tscn"
]

# Leader abilities and information
var leadersDesc = [
	"William:\nNo constant bonus.\nPower - Hackathon. Attacking with units will disable the enemy units for one turn. \nLeader of the Computer Science Club.",
	"Sally:\nUnits on properties gain a +40% attack bonus.\nPower - Liquidation. Gain funds equal to 50% of the damage dealth when attacking enemy units. \nLeader of the Finance Region.",
	"RedLine: Sanic",
	"Kronk: KRONK"
]

# Levels
var levels = [
	"res://Scenes/Level1.tscn",
	"res://Scenes/Level2.tscn",
	"res://Scenes/Level3.tscn",
	"res://Scenes/Level4.tscn",
	"res://Scenes/Level5.tscn"
]

# Level Intros
var level_intros = [
	"res://Dialog/Level1Intro.json",
	"res://Dialog/Level2Intro.json",
	"res://Dialog/Level3Intro.json",
	"res://Dialog/Level4Intro.json",
	"res://Dialog/Level5Intro.json"
]

var intro_scenes = [
	"res://Scenes/Level1Intro.tscn",
	"res://Scenes/Level2Intro.tscn",
	"res://Scenes/Level3Intro.tscn",
	"res://Scenes/Level4Intro.tscn",
	"res://Scenes/Level5Intro.tscn"
]
