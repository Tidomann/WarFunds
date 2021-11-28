extends Node

# Selected Leader
var path = "res://Objects/Commanders/William.tscn"
var intro_dialogue = "res://Dialog/GameIntro.json"
var next_level = "res://Scenes/Select.tscn"

# Currently Unlocked Leaders and Levels
var unlockedLeaders = [true,false,false,false,false,false,false,false]
var unlockedLevels = [true,false,false,false,false,false,false,false]

# Leader Images
var leaders = [
	"res://assets/Sprites/DepartmentLeaders/William/WilliamNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Kronk/KronkNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Redline/RedlineNeutral.png"	
]

# Path to leader scene
var leaderPath = [
	"res://Objects/Commanders/William.tscn",
	"res://Objects/Commanders/Kronk.tscn",
	"res://Objects/Commanders/RedLine.tscn"
]

# Leader abilities and information
var leadersDesc = [
	"William: Power - Hackathon. For one turn, units will disable enemies for one turn. Leader of the Computer Science Club, William has no advantages or disadvantages, which is an advantage itself.",
	"Kronk: Boi",
	"RedLine: ioB"
]

# Levels
var levels = [
	"res://Scenes/Level1.tscn",
	"res://Scenes/Level2.tscn"
]

# Level Intros
var level_intros = [
	"res://Dialog/Level1Intro.json",
	"res://Dialog/Level2Intro.json"
]

var intro_scenes = [
	"res://Scenes/Level1Intro.tscn",
	"res://Scenes/Level2Intro.tscn"
]
