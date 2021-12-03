extends TextureRect
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var _unitsort = get_parent().get_node("GameBoard/Units")
onready var gamegrid = get_parent().gamegrid
var junior = preload("res://Objects/Units/Junior.tscn")
var senior = preload("res://Objects/Units/Senior.tscn")
var bsenior = preload("res://Objects/Units/Book-zooka Senior.tscn")
var scanner = preload("res://Objects/Units/Scanner.tscn")
var printer = preload("res://Objects/Units/Printer.tscn")
var stapler = preload("res://Objects/Units/Stapler.tscn")
var fax = preload("res://Objects/Units/Fax.tscn")

var base_position : Vector2
var grid_position : Vector2
var player : Node2D

var juniorcost: int
var seniorcost: int
var bseniorcost: int
var scannercost: int
var printercost: int
var staplercost: int
var faxcost: int

# Called when the node enters the scene tree for the first time.
func _ready():
	var new_junior = junior.instance()
	var new_senior = senior.instance()
	var new_bsenior = bsenior.instance()
	var new_scanner = scanner.instance()
	var new_printer = printer.instance()
	var new_stapler = stapler.instance()
	var new_fax = fax.instance()
	juniorcost = new_junior.cost
	seniorcost = new_senior.cost
	bseniorcost = new_bsenior.cost
	scannercost = new_scanner.cost
	printercost = new_printer.cost
	staplercost = new_stapler.cost
	faxcost = new_fax.cost
	new_junior.queue_free()
	new_senior.queue_free()
	new_bsenior.queue_free()
	new_scanner.queue_free()
	new_printer.queue_free()
	new_stapler.queue_free()
	$VBoxContainer/Junior/JuniorButton.text = "$"+String(juniorcost)
	$VBoxContainer/Senior/SeniorButton.text = "$"+String(seniorcost)
	$VBoxContainer/BSenior/bSeniorButton.text = "$"+String(bseniorcost)
	$VBoxContainer/Scanner/ScannerButton.text = "$"+String(scannercost)
	$VBoxContainer/Printer/PrinterButton.text = "$"+String(printercost)
	$VBoxContainer/Stapler/Staplerbutton.text = "$"+String(staplercost)
	$VBoxContainer/Fax/FaxButton.text = "$"+String(faxcost)

func popup_menu(inbase_position: Vector2, grid_coordinate: Vector2, inplayer: Node2D) -> void:
	$VBoxContainer/Junior/JuniorButton.text = "$"+String(int(juniorcost*inplayer.commander.get_unit_cost_multiplier()))
	$VBoxContainer/Senior/SeniorButton.text = "$"+String(int(seniorcost*inplayer.commander.get_unit_cost_multiplier()))
	$VBoxContainer/BSenior/bSeniorButton.text = "$"+String(int(bseniorcost*inplayer.commander.get_unit_cost_multiplier()))
	$VBoxContainer/Scanner/ScannerButton.text = "$"+String(int(scannercost*inplayer.commander.get_unit_cost_multiplier()))
	$VBoxContainer/Printer/PrinterButton.text = "$"+String(int(printercost*inplayer.commander.get_unit_cost_multiplier()))
	$VBoxContainer/Stapler/Staplerbutton.text = "$"+String(int(staplercost*inplayer.commander.get_unit_cost_multiplier()))
	$VBoxContainer/Fax/FaxButton.text = "$"+String(faxcost)
	base_position = inbase_position
	grid_position = grid_coordinate
	player = inplayer
	army_color_set(inplayer)
	test_funds(inplayer.funds)
	# 480 x 270 window size
	# 80x170 menu size
	self.rect_global_position = inbase_position
	if inbase_position.x >= 240:
		self.rect_global_position += Vector2(-96,0)
	else:
		self.rect_global_position += Vector2(16,0)
	if inbase_position.y >= 100:
		self.rect_global_position.y = 100 
	else:
		self.rect_global_position.y = inbase_position.y
	show()
	$VBoxContainer/Junior/JuniorButton.grab_focus()

func _on_JuniorButton_pressed():
	player.addFunds(-int(juniorcost*player.commander.get_unit_cost_multiplier()))
	var new_junior = junior.instance()
	_unitsort.add_child(new_junior)
	new_junior.playerOwner = player
	new_junior.cell = grid_position
	new_junior.army_color_set()
	new_junior.set_flip()
	new_junior.update_position()
	if new_junior.is_turnReady():
		new_junior.flip_turnReady()
	gamegrid.get_GridData_by_position(grid_position).unit = new_junior
	$SoundMenuButtonClick.play()
	print(player.commander.get_unit_cost(new_junior))
	hide()


func _on_SeniorButton_pressed():
	player.addFunds(-int(seniorcost*player.commander.get_unit_cost_multiplier()))
	var new_senior = senior.instance()
	_unitsort.add_child(new_senior)
	new_senior.playerOwner = player
	new_senior.cell = grid_position
	new_senior.army_color_set()
	new_senior.set_flip()
	new_senior.update_position()
	if new_senior.is_turnReady():
		new_senior.flip_turnReady()
	gamegrid.get_GridData_by_position(grid_position).unit = new_senior
	$SoundMenuButtonClick.play()
	hide()


func _on_bSeniorButton_pressed():
	player.addFunds(-int(bseniorcost*player.commander.get_unit_cost_multiplier()))
	var new_bsenior = bsenior.instance()
	_unitsort.add_child(new_bsenior)
	new_bsenior.playerOwner = player
	new_bsenior.cell = grid_position
	new_bsenior.army_color_set()
	new_bsenior.set_flip()
	new_bsenior.update_position()
	if new_bsenior.is_turnReady():
		new_bsenior.flip_turnReady()
	gamegrid.get_GridData_by_position(grid_position).unit = new_bsenior
	$SoundMenuButtonClick.play()
	hide()


func _on_ScannerButton_pressed():
	player.addFunds(-int(scannercost*player.commander.get_unit_cost_multiplier()))
	var new_scanner = scanner.instance()
	_unitsort.add_child(new_scanner)
	new_scanner.playerOwner = player
	new_scanner.cell = grid_position
	new_scanner.army_color_set()
	new_scanner.set_flip()
	new_scanner.update_position()
	if new_scanner.is_turnReady():
		new_scanner.flip_turnReady()
	gamegrid.get_GridData_by_position(grid_position).unit = new_scanner
	$SoundMenuButtonClick.play()
	hide()


func _on_PrinterButton_pressed():
	player.addFunds(-int(printercost*player.commander.get_unit_cost_multiplier()))
	var new_printer = printer.instance()
	_unitsort.add_child(new_printer)
	new_printer.playerOwner = player
	new_printer.cell = grid_position
	new_printer.army_color_set()
	new_printer.set_flip()
	new_printer.update_position()
	if new_printer.is_turnReady():
		new_printer.flip_turnReady()
	gamegrid.get_GridData_by_position(grid_position).unit = new_printer
	$SoundMenuButtonClick.play()
	hide()


func _on_Staplerbutton_pressed():
	player.addFunds(-int(staplercost*player.commander.get_unit_cost_multiplier()))
	var new_stapler = stapler.instance()
	_unitsort.add_child(new_stapler)
	new_stapler.playerOwner = player
	new_stapler.cell = grid_position
	new_stapler.army_color_set()
	new_stapler.set_flip()
	new_stapler.update_position()
	if new_stapler.is_turnReady():
		new_stapler.flip_turnReady()
	gamegrid.get_GridData_by_position(grid_position).unit = new_stapler
	$SoundMenuButtonClick.play()
	hide()


func _on_FaxButton_pressed():
	player.addFunds(-int(faxcost*player.commander.get_unit_cost_multiplier()))
	var new_fax = fax.instance()
	_unitsort.add_child(new_fax)
	new_fax.playerOwner = player
	new_fax.cell = grid_position
	new_fax.army_color_set()
	new_fax.set_flip()
	new_fax.update_position()
	if new_fax.is_turnReady():
		new_fax.flip_turnReady()
	gamegrid.get_GridData_by_position(grid_position).unit = new_fax
	$SoundMenuButtonClick.play()
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _unhandled_input(event: InputEvent) -> void:
	if self.visible:
		if event.is_action_pressed("ui_cancel"):
			$SoundMenuButtonCancel.play()
			hide()
			get_tree().set_input_as_handled()
		if event is InputEventMouseButton:
			if event.is_pressed():
				if not get_rect().has_point(event.position):
					$SoundMenuButtonCancel.play()
					hide()
					get_tree().set_input_as_handled()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT:
			$SoundMenuButtonCancel.play()
			hide()
			get_tree().set_input_as_handled()

func army_color_set(playerOwner: Node2D) -> void:
	match playerOwner.commander.army_type:
		Constants.ARMY.ENGINEERING:
			match playerOwner.player_colour:
				Constants.COLOUR.RED:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("eRed")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("eRed")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("eRed")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Red")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Red")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Red")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Red")
				Constants.COLOUR.BLUE:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("eBlue")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("eBlue")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("eBlue")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Blue")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Blue")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Blue")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Blue")
				Constants.COLOUR.GREEN:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("eGreen")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("eGreen")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("eGreen")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Green")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Green")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Green")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Green")
				Constants.COLOUR.YELLOW:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("eYellow")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("eYellow")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("eYellow")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Yellow")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Yellow")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Yellow")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Yellow")
				Constants.COLOUR.CYAN:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("eCyan")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("eCyan")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("eCyan")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Cyan")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Cyan")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Cyan")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Cyan")
				Constants.COLOUR.PURPLE:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("ePurple")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("ePurple")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("ePurple")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Purple")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Purple")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Purple")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Purple")
		Constants.ARMY.COSC:
			match playerOwner.player_colour:
				Constants.COLOUR.RED:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("cRed")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("cRed")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("cRed")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Red")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Red")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Red")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Red")
				Constants.COLOUR.BLUE:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("cBlue")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("cBlue")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("cBlue")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Blue")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Blue")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Blue")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Blue")
				Constants.COLOUR.GREEN:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("cGreen")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("cGreen")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("cGreen")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Green")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Green")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Green")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Green")
				Constants.COLOUR.YELLOW:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("cYellow")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("cYellow")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("cYellow")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Yellow")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Yellow")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Yellow")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Yellow")
				Constants.COLOUR.CYAN:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("cCyan")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("cCyan")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("cCyan")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Cyan")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Cyan")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Cyan")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Cyan")
				Constants.COLOUR.PURPLE:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("cPurple")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("cPurple")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("cPurple")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Purple")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Purple")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Purple")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Purple")
		Constants.ARMY.BIOLOGY:
			match playerOwner.player_colour:
				Constants.COLOUR.RED:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("sRed")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("sRed")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("sRed")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Red")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Red")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Red")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Red")
				Constants.COLOUR.BLUE:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("sBlue")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("sBlue")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("sBlue")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Blue")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Blue")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Blue")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Blue")
				Constants.COLOUR.GREEN:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("sGreen")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("sGreen")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("sGreen")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Green")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Green")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Green")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Green")
				Constants.COLOUR.YELLOW:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("sYellow")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("sYellow")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("sYellow")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Yellow")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Yellow")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Yellow")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Yellow")
				Constants.COLOUR.CYAN:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("sCyan")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("sCyan")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("sCyan")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Cyan")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Cyan")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Cyan")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Cyan")
				Constants.COLOUR.PURPLE:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("sPurple")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("sPurple")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("sPurple")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Purple")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Purple")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Purple")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Purple")
		Constants.ARMY.FINANCE:
			match playerOwner.player_colour:
				Constants.COLOUR.RED:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("fRed")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("fRed")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("fRed")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Red")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Red")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Red")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Red")
				Constants.COLOUR.BLUE:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("fBlue")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("fBlue")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("fBlue")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Blue")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Blue")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Blue")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Blue")
				Constants.COLOUR.GREEN:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("fGreen")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("fGreen")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("fGreen")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Green")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Green")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Green")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Green")
				Constants.COLOUR.YELLOW:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("fYellow")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("fYellow")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("fYellow")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Yellow")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Yellow")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Yellow")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Yellow")
				Constants.COLOUR.CYAN:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("fCyan")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("fCyan")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("fCyan")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Cyan")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Cyan")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Cyan")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Cyan")
				Constants.COLOUR.PURPLE:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("sPurple")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("sPurple")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("sPurple")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Purple")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Purple")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Purple")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Purple")
		Constants.ARMY.NURSING:
			match playerOwner.player_colour:
				Constants.COLOUR.RED:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("nRed")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("nRed")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("nRed")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Red")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Red")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Red")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Red")
				Constants.COLOUR.BLUE:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("nBlue")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("nBlue")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("nBlue")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Blue")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Blue")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Blue")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Blue")
				Constants.COLOUR.GREEN:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("nGreen")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("nGreen")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("nGreen")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Green")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Green")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Green")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Green")
				Constants.COLOUR.YELLOW:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("nYellow")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("nYellow")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("nYellow")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Yellow")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Yellow")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Yellow")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Yellow")
				Constants.COLOUR.CYAN:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("nCyan")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("nCyan")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("nCyan")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Cyan")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Cyan")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Cyan")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Cyan")
				Constants.COLOUR.PURPLE:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("nPurple")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("nPurple")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("nPurple")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Purple")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Purple")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Purple")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Purple")
		Constants.ARMY.BANKTANIA:
			match playerOwner.player_colour:
				Constants.COLOUR.RED:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("bRed")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("bRed")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("bRed")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Red")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Red")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Red")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Red")
				Constants.COLOUR.BLUE:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("bBlue")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("bBlue")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("bBlue")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Blue")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Blue")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Blue")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Blue")
				Constants.COLOUR.GREEN:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("bGreen")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("bGreen")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("bGreen")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Green")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Green")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Green")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Green")
				Constants.COLOUR.YELLOW:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("bYellow")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("bYellow")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("bYellow")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Yellow")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Yellow")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Yellow")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Yellow")
				Constants.COLOUR.CYAN:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("bCyan")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("bCyan")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("bCyan")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Cyan")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Cyan")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Cyan")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Cyan")
				Constants.COLOUR.PURPLE:
					$VBoxContainer/Junior/Control/JuniorArmyColour.play("bPurple")
					$VBoxContainer/Senior/Control/SeniorArmyColour.play("bPurple")
					$VBoxContainer/BSenior/Control/BSeniorArmyColour.play("bPurple")
					$VBoxContainer/Scanner/Control/ScannerArmyColour.play("Purple")
					$VBoxContainer/Printer/Control/PrinterArmyColour.play("Purple")
					$VBoxContainer/Stapler/Control/StaplerArmyColour.play("Purple")
					$VBoxContainer/Fax/Control/FaxArmyColour.play("Purple")

func test_funds(funds: int) -> void:
	$VBoxContainer/Junior/JuniorButton.disabled = false
	$VBoxContainer/Senior/SeniorButton.disabled = false
	$VBoxContainer/BSenior/bSeniorButton.disabled = false
	$VBoxContainer/Scanner/ScannerButton.disabled = false
	$VBoxContainer/Printer/PrinterButton.disabled = false
	$VBoxContainer/Stapler/Staplerbutton.disabled = false
	$VBoxContainer/Fax/FaxButton.disabled = false
	if funds < juniorcost:
		$VBoxContainer/Junior/JuniorButton.disabled = true
	if funds < seniorcost:
		$VBoxContainer/Senior/SeniorButton.disabled = true
	if funds < bseniorcost:
		$VBoxContainer/BSenior/bSeniorButton.disabled = true
	if funds < scannercost:
		$VBoxContainer/Scanner/ScannerButton.disabled = true
	if funds < printercost:
		$VBoxContainer/Printer/PrinterButton.disabled = true
	if funds < staplercost:
		$VBoxContainer/Stapler/Staplerbutton.disabled = true
	if funds < faxcost:
		$VBoxContainer/Fax/FaxButton.disabled = true
