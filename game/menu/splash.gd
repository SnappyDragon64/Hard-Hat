extends Control


@export var level_complete_splash_texture: Texture2D

var tween: Tween


func init(complete_signal, level_signal):
	complete_signal.connect(_on_complete)
	level_signal.connect(_on_level)


func _on_complete():
	setup_level_complete_splash()
	fade_in()


func _on_level(id: int):
	setup_level_splash(id)
	fade_in()


func fade_in():
	kill_if_tween()
	tween = get_tree().create_tween().set_parallel()
	tween.tween_callback(fade_out).set_delay(1.3)
	tween.tween_property(%ColorRectHolder, "rotation_degrees", -6.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.1)
	tween.tween_property(%TextureRect, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func fade_out():
	kill_if_tween()
	tween = get_tree().create_tween().set_parallel()
	tween.tween_property(%ColorRectHolder, "rotation_degrees", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(%TextureRect, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT).set_delay(0.1)


func setup_level_splash(id: int):
	kill_if_tween()
	var level_splash_texture_path = get_level_splash_texture_path(id)
	var level_splash_texture = load(level_splash_texture_path)
	setup(level_splash_texture)


func setup_level_complete_splash():
	kill_if_tween()
	setup(level_complete_splash_texture)


func setup(texture: Texture2D):
	%TextureRect.set_texture(texture)
	var texture_rect_size = %TextureRect.get_size()
	%ColorRectHolder.set_size(texture_rect_size)
	var color_rect_pivot_offset = texture_rect_size / 2.0
	%ColorRectHolder.set_pivot_offset(color_rect_pivot_offset)
	%ColorRectHolder.set_rotation_degrees(0.0)
	%TextureRect.set_modulate(Color(1.0, 1.0, 1.0, 0.0))


func get_level_splash_texture_path(id: int):
	return "res://assets/sprite/game/splash/level_%d.png" % id


func kill_if_tween():
	if tween:
		tween.kill()
