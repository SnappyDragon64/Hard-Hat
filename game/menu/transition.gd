extends Control


signal popped_in
signal popped_out
signal wait

var rng = RandomNumberGenerator.new()


func pop_in():
	AudioManager.play_sound(AudioRegistry.SFX_TRANSIIION_POP_IN)
	var rot = _get_random_rotation()
	mouse_filter = MOUSE_FILTER_STOP
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($ColorRect, "color", Color(0.0, 0.0, 0.0, 1.0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Control/TextureRect, "position", Vector2(-960.0, -540.0), 0.4).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property($Control/TextureRect, "rotation_degrees", rot, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_property($Control/TextureRect, "rotation_degrees", 0.0, 0.1).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_pop_in_callback)


func _pop_in_callback():
	popped_in.emit()


func pop_out():
	AudioManager.play_sound(AudioRegistry.SFX_TRANSIIION_POP_OUT)
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($ColorRect, "color", Color(0.0, 0.0, 0.0, 0.0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Control/TextureRect, "position", Vector2(-960.0, -1840.0), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.set_parallel(false)
	tween.tween_callback(_pop_out_callback)


func _pop_out_callback():
	popped_out.emit()
	mouse_filter = MOUSE_FILTER_IGNORE


func start_wait():
	$Timer.start()


func _on_timer_timeout():
	wait.emit()


func _get_random_rotation():
	var rot = rng.randf_range(5.0, 15.0)
	var flag = rng.randi_range(0, 1)
	return rot if flag == 1 else -rot
