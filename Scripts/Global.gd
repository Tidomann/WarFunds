extends Node

# Selected Leader
var path = "res://Objects/Commanders/DrDeficit.tscn"
var intro_dialogue = "res://Dialog/GameIntro.json"
var next_level = "res://Scenes/Select.tscn"
var player_colour = Constants.COLOUR.GREEN

# Currently Unlocked Leaders and Levels
var unlockedLeaders = [true,true,true,true,true,false,false,false]
var unlockedLevels = [true,false,false,false,false,false,false,false]
var unlockedColours = [true,true,true,true,true,true]

# Leader Images
var leaders = [
	"res://assets/Sprites/DepartmentLeaders/William/WilliamNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Sally/SallyNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Dr Deficit/Dr DeficitNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Redline/RedlineNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Kronk/KronkNeutral.png",
]

# Path to leader scene
var leaderPath = [
	"res://Objects/Commanders/William.tscn",
	"res://Objects/Commanders/Sally.tscn",
	"res://Objects/Commanders/DrDeficit.tscn",
	"res://Objects/Commanders/RedLine.tscn",
	"res://Objects/Commanders/Kronk.tscn"
]

# Leader abilities and information
var leadersDesc = [
	"[u][color=#62beff]William[/color][/u]\n[u][color=#62beff]Power[/color][/u]\n[color=#62beff]Hackathon[/color] - Attacking an enemy unit will disable it for one turn.\nLeader of the Computer Science Club.",
	"[u][color=#d39c36]Sally[/color][/u]\nUnits on properties gain a +40% attack bonus.\n[u][color=#d39c36]Power[/color][/u]\n[color=#d39c36]Liquidation[/color] - Gain funds equal to 50% of the damage dealt when attacking enemy units.\nLeader of the Finance Region. Money is power!",
	"[u][color=#30f830]Dr. Deficit[/color][/u]\nEnemy units that are not next to a friendly unit take +20% more damage.\n[u][color=#30f830]Power[/color][/u]\n[color=#30f830]Viral Outbreak[/color] - Enemy units that are next to another unit lose 2HP (cannot kill units).\nHe claims he predicted a grand deficit.",
	"[u][color=#5f4d72]Redline[/color][/u]\n[u][color=#5f4d72]Power[/color][/u]\n[color=#5f4d72]Homestrech[/color] - Units gain +1 movement.\nTime is money!",
	"[u][color=#5f4d72]Kronk[/color][/u]\nUnits have a chance to deal more or less damage.\n[u][color=#5f4d72]Power[/color][/u]\n[color=#5f4d72]Hapless Hero[/color] - Units have a chance to deal a lot more or a lot less damage.\nKronk!"
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
