extends Control


@export var play_silhouette: Texture2D
@export var config_silhouette: Texture2D
@export var quit_silhouette: Texture2D

signal play()
signal play_level(level_id)
signal outro()

var title_screen_lock := false
var title_screen_current_selection: int = 0
var audio_tween: Tween


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


func fade_out_music_submenu():
	if audio_tween:
		audio_tween.kill()
	
	audio_tween = get_tree().create_tween()
	audio_tween.tween_property($AudioStreamPlayer, "volume_db", -40.0, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func fade_in_music_submenu():
	if audio_tween:
		audio_tween.kill()
	
	audio_tween = get_tree().create_tween()
	audio_tween.tween_property($AudioStreamPlayer, "volume_db", -20.0, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)


func _on_title_play_button_mouse_entered():
	if not title_screen_lock and title_screen_current_selection != 0:
		title_screen_current_selection = 0
		title_screen_move_bar(%PlayButton)
		%BackgroundSet.twirl_silhouette(play_silhouette)


func _on_title_config_button_mouse_entered():
	if not title_screen_lock and title_screen_current_selection != 1:
		title_screen_current_selection = 1
		title_screen_move_bar(%ConfigButton)
		%BackgroundSet.twirl_silhouette(config_silhouette)


func _on_title_quit_button_mouse_entered():
	if not title_screen_lock and title_screen_current_selection != 2:
		title_screen_current_selection = 2
		title_screen_move_bar(%QuitButton)
		%BackgroundSet.twirl_silhouette(quit_silhouette)


func _on_title_screen_play_button_pressed():
	AudioManager.play_sound(AudioRegistry.SFX_CONFIRM)
	%PlayButton.release_focus()
	title_screen_handle_button_press(title_screen_play)


func _on_title_screen_config_button_pressed():
	AudioManager.play_sound(AudioRegistry.SFX_CONFIRM)
	%ConfigButton.release_focus()
	title_screen_handle_button_press(title_screen_config)


func _on_title_screen_quit_button_pressed():
	AudioManager.play_sound(AudioRegistry.SFX_CONFIRM)
	%QuitButton.release_focus()
	title_screen_handle_button_press(title_screen_quit)


func title_screen_play():
	if SaveManager.check("intro_viewed"):
		show_level_select()
	else:
		play.emit()


var pause_tween: Tween
var level_select_active := false
var highlight_tween: Tween


func show_level_select():
	fade_out_music_submenu()
	level_select_active = true
	
	if pause_tween:
		pause_tween.kill()
	
	$LevelSelectHolder.set_visible(true)
	AudioManager.play_sound(AudioRegistry.SFX_BLUEPRINTS)
	pause_tween = get_tree().create_tween().set_parallel()
	pause_tween.tween_property($LevelSelectHolder, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pause_tween.tween_property(%LevelSelectUI, "position", Vector2(0, 0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	pause_tween.set_parallel(false)
	pause_tween.tween_callback(_on_show_level_select)


func _on_show_level_select():
	reset_bar()


func hide_level_select():
	fade_in_music_submenu()
	level_select_active = false
	
	if pause_tween:
		pause_tween.kill()
	
	AudioManager.play_sound(AudioRegistry.SFX_BLUEPRINTS)
	pause_tween = get_tree().create_tween().set_parallel()
	pause_tween.tween_property($LevelSelectHolder, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pause_tween.tween_property(%LevelSelectUI, "position", Vector2(-1300.0, 0.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	pause_tween.set_parallel(false)
	pause_tween.tween_callback(_on_hide_level_select)


func _input(_event: InputEvent):
	if level_select_active and Input.is_action_just_pressed("escape"):
		hide_level_select()


func _on_hide_level_select():
	title_screen_lock = false
	$LevelSelectHolder.set_visible(false)


func title_screen_config():
	pass


func title_screen_quit():
	get_tree().quit()


func title_screen_move_bar(button):
	if not title_screen_lock:
		var button_pos = button.get_global_position()
		var bar_pos = %Bar.get_global_position()
		bar_pos.y = button_pos.y + 24
		
		var tween = get_tree().create_tween()
		tween.tween_property(%Bar, "global_position", bar_pos, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func title_screen_handle_button_press(callable):
	if not title_screen_lock:
		title_screen_lock = true
		var bar_pos = %Bar.get_global_position()
		var bar_final_pos = Vector2(-600, bar_pos.y)
		
		var tween = get_tree().create_tween()
		tween.tween_property(%Bar, "global_position", bar_final_pos, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_callback(callable)


func reset_bar():
	var bar_pos = %Bar.get_global_position()
	%Bar.global_position = Vector2(0, bar_pos.y)


var level_2_unlocked := false
var level_3_unlocked := false
var level_4_unlocked := false
var end_card_unlocked := false


func _ready():
	var disabled_color := Color(0.5, 0.5, 0.5)
	
	level_2_unlocked = SaveManager.check("level_1_completed")
	level_3_unlocked = SaveManager.check("level_2_completed")
	level_4_unlocked = SaveManager.check("level_3_completed")
	end_card_unlocked = SaveManager.check("level_4_completed")
	
	if not level_2_unlocked:
		%Level2.modulate = disabled_color
	if not level_3_unlocked:
		%Level3.modulate = disabled_color
	if not level_4_unlocked:
		%Level4.modulate = disabled_color
	if not end_card_unlocked:
		%EndCard.modulate = disabled_color


func _on_level_1_mouse_entered():
	toggle_highlights(%Level1, %Level2, %Level3, %Level4, %IntroComic, %EndCard, )


func _on_level_2_mouse_entered():
	if level_2_unlocked:
		toggle_highlights(%Level2, %Level3, %Level4, %IntroComic, %EndCard, %Level1)


func _on_level_3_mouse_entered():
	if level_3_unlocked:
		toggle_highlights(%Level3, %Level4, %IntroComic, %EndCard, %Level1, %Level2)


func _on_level_4_mouse_entered():
	if level_4_unlocked:
		toggle_highlights(%Level4, %IntroComic, %EndCard, %Level1, %Level2, %Level3)


func _on_intro_comic_mouse_entered():
	toggle_highlights(%IntroComic, %EndCard, %Level1, %Level2, %Level3, %Level4)


func _on_end_card_mouse_entered():
	if end_card_unlocked:
		toggle_highlights(%EndCard, %Level1, %Level2, %Level3, %Level4, %IntroComic)


func toggle_highlights(to_enable, to_disable_1, to_disable_2, to_disable_3, to_disable_4, to_disable_5):
	var duration := 0.2
	var highlight_to_enable = get_button_highlight(to_enable)
	var highlight_to_disable_1 = get_button_highlight(to_disable_1)
	var highlight_to_disable_2 = get_button_highlight(to_disable_2)
	var highlight_to_disable_3 = get_button_highlight(to_disable_3)
	var highlight_to_disable_4 = get_button_highlight(to_disable_4)
	var highlight_to_disable_5 = get_button_highlight(to_disable_5)
	
	if highlight_tween:
		highlight_tween.kill()
	
	highlight_tween = get_tree().create_tween().set_parallel()
	highlight_tween.tween_property(highlight_to_enable, "modulate", Color(1.0, 1.0, 1.0, 1.0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	highlight_tween.tween_property(highlight_to_enable, "rotation_degrees", -6.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	highlight_tween.tween_property(highlight_to_disable_1, "modulate", Color(1.0, 1.0, 1.0, 0.0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	highlight_tween.tween_property(highlight_to_disable_1, "rotation_degrees", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	highlight_tween.tween_property(highlight_to_disable_2, "modulate", Color(1.0, 1.0, 1.0, 0.0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	highlight_tween.tween_property(highlight_to_disable_2, "rotation_degrees", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	highlight_tween.tween_property(highlight_to_disable_3, "modulate", Color(1.0, 1.0, 1.0, 0.0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	highlight_tween.tween_property(highlight_to_disable_3, "rotation_degrees", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	highlight_tween.tween_property(highlight_to_disable_4, "modulate", Color(1.0, 1.0, 1.0, 0.0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	highlight_tween.tween_property(highlight_to_disable_4, "rotation_degrees", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	highlight_tween.tween_property(highlight_to_disable_5, "modulate", Color(1.0, 1.0, 1.0, 0.0), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	highlight_tween.tween_property(highlight_to_disable_5, "rotation_degrees", 0.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func immediately_toggle_highlights(to_enable, to_disable_1, to_disable_2, to_disable_3, to_disable_4, to_disable_5):
	var highlight_to_enable = get_button_highlight(to_enable)
	var highlight_to_disable_1 = get_button_highlight(to_disable_1)
	var highlight_to_disable_2 = get_button_highlight(to_disable_2)
	var highlight_to_disable_3 = get_button_highlight(to_disable_3)
	var highlight_to_disable_4 = get_button_highlight(to_disable_4)
	var highlight_to_disable_5 = get_button_highlight(to_disable_5)
	
	highlight_to_enable.modulate = Color(1.0, 1.0, 1.0, 1.0)
	highlight_to_enable.rotation_degrees = -6.0
	highlight_to_disable_1.modulate = Color(1.0, 1.0, 1.0, 0.0)
	highlight_to_disable_1.rotation_degrees = 0.0
	highlight_to_disable_2.modulate = Color(1.0, 1.0, 1.0, 0.0)
	highlight_to_disable_2.rotation_degrees = 0.0
	highlight_to_disable_3.modulate = Color(1.0, 1.0, 1.0, 0.0)
	highlight_to_disable_3.rotation_degrees = 0.0
	highlight_to_disable_4.modulate = Color(1.0, 1.0, 1.0, 0.0)
	highlight_to_disable_4.rotation_degrees = 0.0
	highlight_to_disable_5.modulate = Color(1.0, 1.0, 1.0, 0.0)
	highlight_to_disable_5.rotation_degrees = 0.0


func back_to_level_select(button_to_highlight):
	level_select_active = true
	title_screen_lock = true
	$LevelSelectHolder.set_visible(true)
	$LevelSelectHolder.modulate = Color(1.0, 1.0, 1.0, 1.0)
	%LevelSelectUI.position = Vector2(0, 0)
	
	match button_to_highlight:
		0:
			immediately_toggle_highlights(%Level1, %Level2, %Level3, %Level4, %IntroComic, %EndCard)
		1:
			immediately_toggle_highlights(%Level2, %Level3, %Level4, %IntroComic, %EndCard, %Level1)
		2:
			immediately_toggle_highlights(%Level3, %Level4, %IntroComic, %EndCard, %Level1, %Level2)
		3:
			immediately_toggle_highlights(%Level4, %IntroComic, %EndCard, %Level1, %Level2, %Level3)
		4:
			immediately_toggle_highlights(%IntroComic, %EndCard, %Level1, %Level2, %Level3, %Level4)
		5:
			immediately_toggle_highlights(%EndCard, %Level1, %Level2, %Level3, %Level4, %IntroComic)


func get_button_highlight(button):
	return button.get_node("Highlight")


func _on_level_1_pressed():
	%Level1.release_focus()
	play_level.emit(1)


func _on_level_2_pressed():
	%Level2.release_focus()
	
	if level_2_unlocked:
		play_level.emit(2)


func _on_level_3_pressed():
	%Level3.release_focus()
	
	if level_3_unlocked:
		play_level.emit(3)


func _on_level_4_pressed():
	%Level4.release_focus()
	
	if level_4_unlocked:
		play_level.emit(4)


func _on_intro_comic_pressed():
	%IntroComic.release_focus()
	play.emit()


func _on_end_card_pressed():
	%EndCard.release_focus()
	
	if end_card_unlocked:
		outro.emit()
