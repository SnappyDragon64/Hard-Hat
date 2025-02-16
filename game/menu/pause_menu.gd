extends Control


signal resume_pressed()
signal restart_pressed()
signal quit_pressed()

@export var texture_one: CompressedTexture2D
@export var texture_two: CompressedTexture2D
@export var texture_three: CompressedTexture2D
@export var duration := 0.2

var unpause_tween: Tween
var highlight_tween: Tween


func init(pause_signal, unpause_signal, reset_signal):
	pause_signal.connect(_on_pause)
	unpause_signal.connect(_on_unpause)
	reset_signal.connect(_on_reset)


func _on_pause():
	if unpause_tween:
		unpause_tween.kill()
		$Countdown.set_visible(false)
	
	var highlight_resume = get_button_highlight(%Resume)
	highlight_resume.set_modulate(Color(1.0, 1.0, 1.0, 1.0))
	highlight_resume.set_rotation_degrees(-6.0)
	
	var highlight_restart = get_button_highlight(%Restart)
	highlight_restart.set_modulate(Color(1.0, 1.0, 1.0, 0.0))
	highlight_restart.set_rotation_degrees(0.0)
	
	var highlight_quit = get_button_highlight(%Quit)
	highlight_quit.set_modulate(Color(1.0, 1.0, 1.0, 0.0))
	highlight_quit.set_rotation_degrees(0.0)
	
	AudioManager.play_sound(AudioRegistry.SFX_BLUEPRINTS)
	$Filter.set_visible(true)
	$PauseLeft.set_visible(true)
	$Holder/PauseRight.set_visible(true)
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($Filter, "color", Color(0.0, 0.17, 0.29, 0.60), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($PauseLeft, "position", Vector2(0, 0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($PauseLeft, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($Holder/PauseRight, "position", Vector2(-720, -1080), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($Holder/PauseRight, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_unpause():
	AudioManager.play_sound(AudioRegistry.SFX_BLUEPRINTS)
	AudioManager.play_sound(AudioRegistry.SFX_TICK)
	$Countdown.set_texture(texture_three)
	$Countdown.set_visible(true)
	unpause_tween = get_tree().create_tween().set_parallel()
	unpause_tween.tween_property($Filter, "color", Color(0.0, 0.17, 0.29, 0.0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	unpause_tween.tween_property($PauseLeft, "position", Vector2(-500, -500), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	unpause_tween.tween_property($PauseLeft, "modulate", Color(1.0, 1.0, 1.0, 0.0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	unpause_tween.tween_property($Holder/PauseRight, "position", Vector2(-200, -400), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	unpause_tween.tween_property($Holder/PauseRight, "modulate", Color(1.0, 1.0, 1.0, 0.0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	unpause_tween.tween_callback(_update_countdown_to_two).set_delay(0.75)
	unpause_tween.tween_callback(_update_countdown_to_one).set_delay(1.5)
	unpause_tween.tween_callback(_hide_countdown).set_delay(2.25)
	unpause_tween.set_parallel(false)
	unpause_tween.tween_callback(_hide)


func _on_reset():
	%Restart.release_focus()
	$Filter.set_color(Color(0.0, 0.17, 0.29, 0.0))
	$PauseLeft.set_position(Vector2(-500, -500))
	$PauseLeft.set_modulate(Color(1.0, 1.0, 1.0, 0.0))
	$Holder/PauseRight.set_position(Vector2(-200, -400))
	$Holder/PauseRight.set_modulate(Color(1.0, 1.0, 1.0, 0.0))


func _hide():
	$Filter.set_visible(false)
	$PauseLeft.set_visible(false)
	$Holder/PauseRight.set_visible(false)


func _update_countdown_to_two():
	AudioManager.play_sound(AudioRegistry.SFX_TICK)
	$Countdown.set_texture(texture_two)


func _update_countdown_to_one():
	AudioManager.play_sound(AudioRegistry.SFX_TICK)
	$Countdown.set_texture(texture_one)


func _hide_countdown():
	AudioManager.play_sound(AudioRegistry.SFX_TICK)
	$Countdown.set_visible(false)


func _on_resume_pressed():
	%Resume.release_focus()
	resume_pressed.emit()


func _on_restart_pressed():
	restart_pressed.emit()


func _on_quit_pressed():
	%Quit.release_focus()
	quit_pressed.emit()


func _on_resume_mouse_entered():
	toggle_highlights(%Resume, %Restart, %Quit)


func _on_restart_mouse_entered():
	toggle_highlights(%Restart, %Resume, %Quit)


func _on_quit_mouse_entered():
	toggle_highlights(%Quit, %Resume, %Restart)


func toggle_highlights(to_enable, to_disable_1, to_disable_2):
	var highlight_to_enable = get_button_highlight(to_enable)
	var highlight_to_disable_1 = get_button_highlight(to_disable_1)
	var highlight_to_disable_2 = get_button_highlight(to_disable_2)
	
	if highlight_tween:
		highlight_tween.kill()
	
	highlight_tween = get_tree().create_tween().set_parallel()
	highlight_tween.tween_property(highlight_to_enable, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	highlight_tween.tween_property(highlight_to_enable, "rotation_degrees", -6.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	highlight_tween.tween_property(highlight_to_disable_1, "modulate", Color(1.0, 1.0, 1.0, 0.0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	highlight_tween.tween_property(highlight_to_disable_1, "rotation_degrees", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	highlight_tween.tween_property(highlight_to_disable_2, "modulate", Color(1.0, 1.0, 1.0, 0.0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	highlight_tween.tween_property(highlight_to_disable_2, "rotation_degrees", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func get_button_highlight(button):
	return button.get_node("Highlight")
