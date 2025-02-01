extends Control


signal init_sandbox()

var title_screen_lock = false
var title_screen_current_selection = 0

func _on_title_play_button_mouse_entered():
	if title_screen_current_selection != 0:
		title_screen_current_selection = 0
		title_screen_move_bar(%PlayButton)
		%BackgroundSet.twirl_silhouette()


func _on_title_config_button_mouse_entered():
	if title_screen_current_selection != 1:
		title_screen_current_selection = 1
		title_screen_move_bar(%ConfigButton)
		%BackgroundSet.twirl_silhouette()


func _on_title_quit_button_mouse_entered():
	if title_screen_current_selection != 2:
		title_screen_current_selection = 2
		title_screen_move_bar(%QuitButton)
		%BackgroundSet.twirl_silhouette()


func _on_title_screen_play_button_pressed():
	%PlayButton.release_focus()
	title_screen_handle_button_press(title_screen_play)


func _on_title_screen_config_button_pressed():
	%ConfigButton.release_focus()
	title_screen_handle_button_press(title_screen_config)


func _on_title_screen_quit_button_pressed():
	%QuitButton.release_focus()
	title_screen_handle_button_press(title_screen_quit)


func title_screen_play():
	$TitleScreenUI.set_visible(false)
	init_sandbox.emit()


func title_screen_config():
	%BackgroundSet.hide_main_menu_props()
	$TitleScreenUI.set_visible(false)
	%BackgroundSet.tween_camera_rotation(120)


func title_screen_quit():
	get_tree().quit()


func title_screen_move_bar(button):
	if not title_screen_lock:
		var button_pos = button.get_global_position()
		var bar_pos = %Bar.get_global_position()
		bar_pos.y = button_pos.y + 24
		
		var tween = get_tree().create_tween()
		tween.tween_property(%Bar, "global_position", bar_pos, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		print(bar_pos)


func title_screen_handle_button_press(callable):
	if not title_screen_lock:
		title_screen_lock = true
		var bar_pos = %Bar.get_global_position()
		var bar_final_pos = Vector2(-600, bar_pos.y)
		
		var tween = get_tree().create_tween().set_parallel()
		tween.tween_property($TitleScreenUI, "self_modulate", Color(1.0, 1.0, 1.0, 0.0), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(%Bar, "global_position", bar_final_pos, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.set_parallel(false)
		tween.tween_callback(callable)
		
