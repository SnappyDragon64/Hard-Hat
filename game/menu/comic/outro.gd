extends Control


signal finished()

var audio_tween: Tween
var lock := true


func _input(_event):
	if Input.is_action_just_pressed("continue") and not lock:
		lock = true
		on_finish()


func play():
	fade_in_music()
	AudioManager.play_sound(AudioRegistry.SFX_COMIC_INTRO)
	lock = true
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($Container, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Container, "position", Vector2(0.0, 0.0), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Container, "rotation_degrees", 0.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_unlock)


func on_finish():
	fade_out_music()
	SaveManager.update("outro_viewed", true)
	finished.emit()


func _unlock():
	lock = false


func fade_in_music():
	$AudioStreamPlayer.set_volume_db(-60.0)
	$AudioStreamPlayer.play(0.0)
	
	if audio_tween:
		audio_tween.kill()
	
	audio_tween = get_tree().create_tween()
	audio_tween.tween_property($AudioStreamPlayer, "volume_db", -20.0, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)


func fade_out_music():
	if audio_tween:
		audio_tween.kill()
	
	audio_tween = get_tree().create_tween()
	audio_tween.tween_property($AudioStreamPlayer, "volume_db", -60.0, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
