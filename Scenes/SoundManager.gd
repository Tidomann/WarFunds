extends Node2D

func _ready():
	pass # Replace with function body.

func playsound(sound:String):
	match sound:
		"Cancel":
			$SoundCancel.play()
		"Select":
			$SoundSelect.play()
		"Heal":
			$SoundHeal.play()
		"InfantryMove":
			$SoundInfantryMove.play()
		"MoveAttackCursor":
			$SoundMoveAttackCursor.play()
		"Attack":
			$SoundAttack.play()
		"CaptureCompleteGood": #Ally team capture
			$SoundCaptureProperty.play()
		"CaptureCompleteBad": #AI team capture
			$SoundLoseProperty.play()
		"CaptureIncomplete":
			$SoundCaptureIncomplete.play()
		"PowerReady":
			$SoundPowerReady.play()
		"Error":
			$SoundError.play()

func stopsound(sound:String):
	match sound:
		"Cancel":
			$SoundCancel.stop()
		"Select":
			$SoundSelect.stop()
		"Heal":
			$SoundHeal.stop()
		"InfantryMove":
			$SoundInfantryMove.stop()
		"MoveAttackCursor":
			$SoundMoveAttackCursor.stop()
		"Attack":
			$SoundAttack.stop()
		"CaptureCompleteGood": #Ally team capture
			$SoundCaptureProperty.stop()
		"CaptureCompleteBad": #AI team capture
			$SoundLoseProperty.stop()
		"CaptureIncomplete":
			$SoundCaptureIncomplete.stop()
		"PowerReady":
			$SoundPowerReady.stop()

func stopallsound() -> void:
	for node in get_children():
		node.stop()
	#$SoundCancel.stop()
	#$SoundSelect.stop()
	#$SoundHeal.stop()
	#$SoundInfantryMove.stop()
	#$SoundMoveAttackCursor.stop()
	#$SoundAttack.stop()
	#$SoundCaptureProperty.stop()
	#$SoundLoseProperty.stop()
	#$SoundCaptureIncomplete.stop()
	#$SoundPowerReady.stop()
