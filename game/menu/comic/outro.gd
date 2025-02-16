extends Control


signal finished()


var lock := true
var done := false


func _input(_event):
	if Input.is_action_just_pressed("continue") and not lock:
		done = true
		on_finish()


func play():
	AudioManager.play_sound(AudioRegistry.SFX_COMIC_INTRO)
	lock = true
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($Container, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Container, "position", Vector2(0.0, 0.0), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Container, "rotation_degrees", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_unlock)


func on_finish():
	SaveManager.update("outro_viewed", true)
	finished.emit()


func _unlock():
	lock = false
