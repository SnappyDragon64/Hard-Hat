extends MarginContainer


var lock_bar = false


func move_bar(button):
	if not lock_bar:
		var button_pos = button.get_global_position()
		var bar_pos = $Bar.get_global_position()
		bar_pos.y = button_pos.y + 24
		
		var tween = get_tree().create_tween()
		tween.tween_property($Bar, "global_position", bar_pos, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func handle_button_press(callable):
	lock_bar = true
	var bar_pos = $Bar.get_global_position()
	var bar_final_pos = Vector2(-600, bar_pos.y)
	
	var tween = get_tree().create_tween()
	tween.tween_property($Bar, "global_position", bar_final_pos, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_callback(callable)


func play():
	Signals.init_sandbox.emit()


func config():
	pass


func exit():
	get_tree().quit()


func _on_play_button_mouse_entered():
	move_bar(%PlayButton)


func _on_config_button_mouse_entered():
	move_bar(%ConfigButton)


func _on_exit_button_mouse_entered():
	move_bar(%ExitButton)


func _on_play_button_pressed():
	handle_button_press(play)
	Signals.hide_main_menu_props.emit()


func _on_config_button_pressed():
	handle_button_press(config)


func _on_exit_button_pressed():
	handle_button_press(exit)
