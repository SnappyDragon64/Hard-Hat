class_name Splash
extends Control


@export var level_complete_splash_texture: Texture2D

var tween: Tween


func queue_fade_out():
	$Timer.start()


func fade_in():
	kill_if_tween()
	tween = get_tree().create_tween().set_parallel()
	tween.tween_property(%ColorRect, "rotation_degrees", -6.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.1)
	tween.tween_property(%TextureRect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func fade_out():
	kill_if_tween()
	tween = get_tree().create_tween().set_parallel()
	tween.tween_property(%ColorRect, "rotation_degrees", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(%TextureRect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT).set_delay(0.1)


func setup_level_splash(id: int):
	kill_if_tween()
	show_splash()
	var level_splash_texture_path = get_level_splash_texture_path(id)
	var level_splash_texture = load(level_splash_texture_path)
	setup(level_splash_texture, -6.0)


func setup_level_complete_splash():
	kill_if_tween()
	setup(level_complete_splash_texture, 0.0)
	hide_splash()


func setup(texture: Texture2D, color_rect_rotation_degrees: float):
	%TextureRect.set_texture(texture)
	var color_rect_pivot_offset = texture.get_size() / 2.0
	%ColorRect.set_pivot_offset(color_rect_pivot_offset)
	%ColorRect.set_rotation_degrees(color_rect_rotation_degrees)


func show_splash():
	%TextureRect.set_modulate(Color(1.0, 1.0, 1.0, 1.0))


func hide_splash():
	%TextureRect.set_modulate(Color(1.0, 1.0, 1.0, 0.0))


func get_level_splash_texture_path(id: int):
	print(id)
	return "res://assets/sprite/game/splash/level_%d.png" % id


func kill_if_tween():
	if tween:
		tween.kill()


func _on_timer_timeout():
	fade_out()
