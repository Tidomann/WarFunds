extends Node

# Selected Leader
var path = "res://Objects/Commanders/William.tscn"
var intro_dialogue = "res://Dialog/GameIntro.json"
var next_level = "res://Scenes/Select.tscn"
var player_colour = Constants.COLOUR.BLUE

# Currently Unlocked Leaders and Levels
var unlockedLeaders = [true,false,false,false,false,false,false,false]
var discoveredLeaders = [true,false,false,false,false,false,false,false]
var unlockedLevels = [true,false,false,false,false,false,false,false, false]
var unlockedColours = [false,true,false,false,false,false]

# Leader Images
var leaders = [
	"res://assets/Sprites/DepartmentLeaders/William/WilliamNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Sally/SallyNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Dr Deficit/Dr DeficitNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Clint/ClintNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Clarissa/ClarissaNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Redline/RedlineNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/Kronk/KronkNeutral.png",
	"res://assets/Sprites/DepartmentLeaders/General Ghani/General GhaniOne.png",
]

# Selected Leaders Images
var leaders_focused = [
	"res://assets/Sprites/DepartmentLeaders/William/WilliamSelected.png",
	"res://assets/Sprites/DepartmentLeaders/Sally/SallySelected.png",
	"res://assets/Sprites/DepartmentLeaders/Dr Deficit/Dr DeficitSelected.png",
	"res://assets/Sprites/DepartmentLeaders/Clint/ClintSelected.png",
	"res://assets/Sprites/DepartmentLeaders/Clarissa/ClarissaSelected.png",
	"res://assets/Sprites/DepartmentLeaders/Redline/RedlineSelected.png",
	"res://assets/Sprites/DepartmentLeaders/Kronk/KronkSelected.png",
	"res://assets/Sprites/DepartmentLeaders/General Ghani/General GhaniSelected.png",
]

# Leader Images
var leaders_discovered = [
	"res://assets/Sprites/DepartmentLeaders/William/WilliamDiscovered.png",
	"res://assets/Sprites/DepartmentLeaders/Sally/SallyDiscovered.png",
	"res://assets/Sprites/DepartmentLeaders/Dr Deficit/Dr DeficitDiscovered.png",
	"res://assets/Sprites/DepartmentLeaders/Clint/ClintDiscovered.png",
	"res://assets/Sprites/DepartmentLeaders/Clarissa/ClarissaDiscovered.png",
	"res://assets/Sprites/DepartmentLeaders/Redline/RedlineDiscovered.png",
	"res://assets/Sprites/DepartmentLeaders/Kronk/KronkDiscovered.png",
	"res://assets/Sprites/DepartmentLeaders/General Ghani/General GhaniDiscovered.png",
]

# Selected Leaders Images
var leaders_discovered_focused = [
	"res://assets/Sprites/DepartmentLeaders/William/WilliamDiscoveredSelected.png",
	"res://assets/Sprites/DepartmentLeaders/Sally/SallyDiscoveredSelected.png",
	"res://assets/Sprites/DepartmentLeaders/Dr Deficit/Dr DeficitDiscoveredSelected.png",
	"res://assets/Sprites/DepartmentLeaders/Clint/ClintDiscoveredSelected.png",
	"res://assets/Sprites/DepartmentLeaders/Clarissa/ClarissaDiscoveredSelected.png",
	"res://assets/Sprites/DepartmentLeaders/Redline/RedlineDiscoveredSelected.png",
	"res://assets/Sprites/DepartmentLeaders/Kronk/KronkDiscoveredSelected.png",
	"res://assets/Sprites/DepartmentLeaders/General Ghani/General GhaniDiscoveredSelected.png",
]

# Path to leader scene
var leaderPath = [
	"res://Objects/Commanders/William.tscn",
	"res://Objects/Commanders/Sally.tscn",
	"res://Objects/Commanders/DrDeficit.tscn",
	"res://Objects/Commanders/Clint.tscn",
	"res://Objects/Commanders/Clarissa.tscn",
	"res://Objects/Commanders/RedLine.tscn",
	"res://Objects/Commanders/Kronk.tscn",
	"res://Objects/Commanders/Ghani.tscn"
]

# Leader abilities and information
var leadersDesc = [
	"[u][color=#62beff]William[/color][/u]\n[u][color=#62beff]Power[/color][/u]\n[color=#62beff]Hackathon[/color] - Attacking an enemy unit will disable it for one turn.\n\nLeader of the Computer Science Club.",
	"[u][color=#d39c36]Sally[/color][/u]\nUnits on properties gain a +40% attack bonus.\n[u][color=#d39c36]Power[/color][/u]\n[color=#d39c36]Liquidation[/color] - Gain funds equal to 50% of the damage dealt when attacking enemy units.\n\nLeader of the Finance Region. Money is power!",
	"[u][color=#30f830]Dr. Deficit[/color][/u]\nEnemy units that are not next to a friendly unit take +20% more damage.\n[u][color=#30f830]Power[/color][/u]\n[color=#30f830]Viral Outbreak[/color] - Enemy units that are next to another unit lose 2HP (cannot kill units).\n\nHe claims he predicted a grand deficit.",
	"[u][color=#aa003f]Clint[/color][/u]\nUnits Units below 5 health gain +20 defense but lose -20% attack. Units 5 health and above gain +20 attack but lose -20% defense.\n[u][color=#aa003f]Power[/color][/u]\n[color=#aa003f]Cram Time[/color] - Bonus and penalty increased to +40%/-40%.\n\nWhy use math when you have lookup tables?",
	"[u][color=#20918b]Clarissa[/color][/u]\nUnits heal 3 life when starting their turn on a property (at no additional cost).\n25% discount on the heal command.\n[u][color=#20918b]Power[/color][/u]\n[color=#20918b]Hyper Heal[/color] - All friendly units gain 2 hitpoints. Sally's units heal 3 hitpoints",
	"[u][color=#5f4d72]Redline[/color][/u]\n[u][color=#5f4d72]Power[/color][/u]\n[color=#5f4d72]Homestrech[/color] - Units gain +1 movement.\n\nTime is money!",
	"[u][color=#5f4d72]Kronk[/color][/u]\nUnits have a chance to deal more or less damage.\n[u][color=#5f4d72]Power[/color][/u]\n[color=#5f4d72]Hapless Hero[/color] - Units have a chance to deal a lot more or a lot less damage.\n\nKronk!",
	"[u][color=#5f4d72]General Ghani[/color][/u]\nUnits cost +20% more to make, but gain +20% attack and defense.\n[u][color=#5f4d72]Power[/color][/u]\n[color=#5f4d72]Sheik's Demand[/color] - Units bonuses increased to +40% attack and +30% defense for the round.\n\nCut them to shreds!"
]

# Levels
var levels = [
	"res://Scenes/Level1.tscn",
	"res://Scenes/Level2.tscn",
	"res://Scenes/Level3.tscn",
	"res://Scenes/Level4.tscn",
	"res://Scenes/Level5.tscn",
	"res://Scenes/Level6.tscn",
	"res://Scenes/Level7.tscn"
]

# Level Intros
var level_intros = [
	"res://Dialog/Level1Intro.json",
	"res://Dialog/Level2Intro.json",
	"res://Dialog/Level3Intro.json",
	"res://Dialog/Level4Intro.json",
	"res://Dialog/Level5Intro.json",
	"res://Dialog/Level6Intro.json",
	"res://Dialog/Level1Intro.json",
]

var intro_scenes = [
	"res://Scenes/Level1Intro.tscn",
	"res://Scenes/Level2Intro.tscn",
	"res://Scenes/Level3Intro.tscn",
	"res://Scenes/Level4Intro.tscn",
	"res://Scenes/Level5Intro.tscn",
	"res://Scenes/Level6Intro.tscn",
	"res://Scenes/Level7.tscn"
]

func save():
	var save_dict = {
		"leaders" : unlockedLeaders,
		"discovered" : discoveredLeaders,
		"levels" : unlockedLevels,
		"colour" : unlockedColours,
		"colour_choice" : player_colour,
		"commander_choice" : path
	}
	return save_dict

func save_game():
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	var game_data = Global.save()
	save_game.store_line(to_json(game_data))
	save_game.close()

func load_game():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return # We don't have a save to load.
	
	save_game.open("user://savegame.save", File.READ)
	while save_game.get_position() < save_game.get_len():
		var game_data = parse_json(save_game.get_line())
		Global.path = game_data["commander_choice"]
		# Json parses as float, but enums are int
		Global.player_colour = int(game_data["colour_choice"])
		Global.unlockedLeaders = game_data["leaders"]
		Global.discoveredLeaders = game_data["discovered"]
		Global.unlockedLevels = game_data["levels"]
		Global.unlockedColours = game_data["colour"]
	save_game.close()
