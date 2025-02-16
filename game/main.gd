extends Node3D


@export var sandbox: PackedScene
@export var main_menu: PackedScene
@export var pause_menu: PackedScene
@export var transition: PackedScene
@export var splash: PackedScene
@export var intro: PackedScene
@export var outro: PackedScene


var transition_instance


func _ready():
	transition_instance = transition.instantiate()
	$Transition.call_deferred("add_child", transition_instance)
	var main_menu_instance = main_menu.instantiate()
	main_menu_instance.play.connect(_on_play)
	main_menu_instance.play_level.connect(_init_sandbox)
	main_menu_instance.outro.connect(_on_outro_main_menu)
	$UI.call_deferred("add_child", main_menu_instance)
	await main_menu_instance.ready
	main_menu_instance.fade_in_music()


func _on_play():
	if SaveManager.check("intro_viewed"):
		attempt_fade_out_music()
		transition_instance.pop_in()
		await transition_instance.popped_in
		var intro_instance = intro.instantiate()
		intro_instance.finished.connect(_intro_return_to_level_select)
		attempt_queue_free("UI/MainMenu")
		$GameUI.call_deferred("add_child", intro_instance)
		await intro_instance.ready
		transition_instance.start_wait()
		await transition_instance.wait
		transition_instance.pop_out()
		await transition_instance.popped_out
		intro_instance.load_next_panel()
	else:
		attempt_fade_out_music()
		transition_instance.pop_in()
		await transition_instance.popped_in
		var intro_instance = intro.instantiate()
		intro_instance.finished.connect(_init_sandbox)
		attempt_queue_free("UI/MainMenu")
		$GameUI.call_deferred("add_child", intro_instance)
		await intro_instance.ready
		transition_instance.start_wait()
		await transition_instance.wait
		transition_instance.pop_out()
		await transition_instance.popped_out
		intro_instance.load_next_panel()


func _intro_return_to_level_select():
	transition_instance.pop_in()
	await transition_instance.popped_in
	attempt_queue_free("GameUI/Intro")
	var main_menu_instance = main_menu.instantiate()
	main_menu_instance.play.connect(_on_play)
	main_menu_instance.play_level.connect(_init_sandbox)
	main_menu_instance.outro.connect(_on_outro_main_menu)
	$UI.call_deferred("add_child", main_menu_instance)
	await main_menu_instance.ready
	main_menu_instance.back_to_level_select(4)
	transition_instance.start_wait()
	await transition_instance.wait
	main_menu_instance.fade_in_music()
	transition_instance.pop_out()
	await transition_instance.popped_out


func _init_sandbox(level_id := 1):
	attempt_fade_out_music()
	transition_instance.pop_in()
	await transition_instance.popped_in
	var sandbox_instance: Sandbox = sandbox.instantiate()
	sandbox_instance.level_id = level_id
	var pause_menu_instance = pause_menu.instantiate()
	var splash_instance = splash.instantiate()
	
	sandbox_instance.quit.connect(_on_quit_sandbox)
	sandbox_instance.outro.connect(_on_outro)
	sandbox_instance.transition_instance = transition_instance
	
	sandbox_instance.init(pause_menu_instance.resume_pressed, pause_menu_instance.restart_pressed, pause_menu_instance.quit_pressed)
	pause_menu_instance.init(sandbox_instance.pause, sandbox_instance.unpause, sandbox_instance.reset_pause_menu)
	sandbox_instance.splash_instance = splash_instance
	
	attempt_queue_free("GameUI/Intro")
	attempt_queue_free("UI/MainMenu")
	call_deferred("add_child", sandbox_instance)
	$GameUI.call_deferred("add_child", splash_instance)
	$GameUI.call_deferred("add_child", pause_menu_instance)


func _on_quit_sandbox():
	attempt_queue_free("GameUI/PauseMenu")
	attempt_queue_free("GameUI/PauseMenu")
	attempt_queue_free("GameUI/Splash")
	attempt_queue_free("Sandbox")
	
	var main_menu_instance = main_menu.instantiate()
	main_menu_instance.play.connect(_on_play)
	main_menu_instance.play_level.connect(_init_sandbox)
	main_menu_instance.outro.connect(_on_outro_main_menu)
	$UI.call_deferred("add_child", main_menu_instance)
	await main_menu_instance.ready
	transition_instance.start_wait()
	await transition_instance.wait
	main_menu_instance.fade_in_music()
	transition_instance.pop_out()
	await transition_instance.popped_out


func _on_outro():
	attempt_queue_free("GameUI/PauseMenu")
	attempt_queue_free("GameUI/Splash")
	attempt_queue_free("Sandbox")
	
	var outro_instance = outro.instantiate()
	outro_instance.finished.connect(_on_outro_finished)
	$GameUI.call_deferred("add_child", outro_instance)
	await outro_instance.ready
	
	transition_instance.start_wait()
	await transition_instance.wait
	transition_instance.pop_out()
	await transition_instance.popped_out
	outro_instance.play()


func _on_outro_finished():
	transition_instance.pop_in()
	await transition_instance.popped_in
	_on_quit_sandbox()


func _on_outro_main_menu():
	attempt_fade_out_music()
	transition_instance.pop_in()
	await transition_instance.popped_in
	attempt_queue_free("UI/MainMenu")
	var outro_instance = outro.instantiate()
	outro_instance.finished.connect(_on_outro_main_menu_finished)
	$GameUI.call_deferred("add_child", outro_instance)
	await outro_instance.ready
	
	transition_instance.start_wait()
	await transition_instance.wait
	transition_instance.pop_out()
	await transition_instance.popped_out
	outro_instance.play()


func _on_outro_main_menu_finished():
	transition_instance.pop_in()
	await transition_instance.popped_in
	attempt_queue_free("GameUI/Outro")
	var main_menu_instance = main_menu.instantiate()
	main_menu_instance.play.connect(_on_play)
	main_menu_instance.play_level.connect(_init_sandbox)
	main_menu_instance.outro.connect(_on_outro_main_menu)
	$UI.call_deferred("add_child", main_menu_instance)
	await main_menu_instance.ready
	main_menu_instance.back_to_level_select(5)
	transition_instance.start_wait()
	await transition_instance.wait
	main_menu_instance.fade_in_music()
	transition_instance.pop_out()
	await transition_instance.popped_out


func attempt_fade_out_music():
	var main_menu_instance = get_node_or_null("UI/MainMenu")
	if main_menu_instance:
		main_menu_instance.fade_out_music()


func attempt_queue_free(node_path):
	var node = get_node_or_null(node_path)
	
	if node:
		node.queue_free()
