extends Control

export var dialogPath = @""
export(float) var textSpeed = 0.05
 
var dialog
var phraseNum = 0
var finished = false

#signal stuff
var isfinished := false
signal dialog_finished(isfinished)
 
func start_dialog():
	dialog = getDialog()
	assert(dialog, "Dialog not found")
	self.visible = true
	phraseNum = 0
	nextPhrase()

func _ready():
	$Timer.wait_time = textSpeed
 
func _process(_delta):
	if self.visible == true:
		$Indicator.visible = finished
		if Input.is_action_just_pressed("ui_accept"):
			if finished:
				$SoundDialog.play()
				nextPhrase()
			else:
				$SoundDialog.play()
				$Text.visible_characters = len($Text.text)
		if Input.is_key_pressed(KEY_ENTER) || Input.is_key_pressed(KEY_KP_ENTER):
			phraseNum = 0
			isfinished = true
			emit_signal("dialog_finished",isfinished)
			self.visible = false
			
 
func getDialog() -> Array:
	var f = File.new()
	assert(f.file_exists(dialogPath), "File path does not exist")
	
	f.open(dialogPath, File.READ)
	var json = f.get_as_text()
	var output = parse_json(json)
	
	if typeof(output) == TYPE_ARRAY:
		return output
	else:
		return []
 
func nextPhrase() -> void:
	if phraseNum >= len(dialog):
		isfinished = true
		emit_signal("dialog_finished",isfinished)
		self.visible = false
		#queue_free()
		return
	finished = false
	$Name.clear()
	$Name.push_underline()
	$Name.add_text(dialog[phraseNum]["Name"])
	$Name.pop()
	$Text.bbcode_text = dialog[phraseNum]["Text"]
	
	$Text.visible_characters = 0
	
	var f = File.new()
	var img = "res://assets/Sprites/DepartmentLeaders/" + dialog[phraseNum]["Name"] + "/" + dialog[phraseNum]["Name"] + dialog[phraseNum]["Emotion"] + ".png"
	if f.file_exists(img):
		$Portrait.texture = load(img)
		var tmp = $Portrait.texture.get_size()
		tmp.x = 64 / tmp.x
		tmp.y = 64/ tmp.y
		$Portrait.scale = tmp
		$Portrait.position.x = 6 + (0.5 * $Portrait.scale.x * $Portrait.texture.get_width())
		$Portrait.position.y = 0.5 * $Portrait.scale.y * -($Portrait.texture.get_height())
	else: $Portrait.texture = null
	
	while $Text.visible_characters < len($Text.text):
		$Text.visible_characters += 1
		
		$Timer.start()
		yield($Timer, "timeout")
	
	finished = true
	phraseNum += 1
	return
