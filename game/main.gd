extends Node3D


@export var sandbox: PackedScene
@export var main_menu: PackedScene
@export var pause_menu: PackedScene
@export var transition: PackedScene
@export var splash: PackedScene

var transition_instance


func _ready():
	var main_menu_instance = main_menu.instantiate()
	main_menu_instance.init_sandbox.connect(_on_init_sandbox)
	$UI.call_deferred("add_child", main_menu_instance)
	
	transition_instance = transition.instantiate()
	$Transition.call_deferred("add_child", transition_instance)


func _on_init_sandbox():
	transition_instance.pop_in()
	await transition_instance.popped_in
	var sandbox_instance: Sandbox = sandbox.instantiate()
	var pause_menu_instance = pause_menu.instantiate()
	var splash_instance = splash.instantiate()
	
	sandbox_instance.quit.connect(_on_quit_sandbox)
	sandbox_instance.transition_instance = transition_instance
	
	sandbox_instance.init(pause_menu_instance.resume_pressed, pause_menu_instance.restart_pressed, pause_menu_instance.quit_pressed)
	pause_menu_instance.init(sandbox_instance.pause, sandbox_instance.unpause, sandbox_instance.reset_pause_menu)
	splash_instance.init(sandbox_instance.complete, sandbox_instance.splash)
	
	$UI/MainMenu.queue_free()
	call_deferred("add_child", sandbox_instance)
	$GameUI.call_deferred("add_child", splash_instance)
	$GameUI.call_deferred("add_child", pause_menu_instance)


func _on_quit_sandbox():
	$GameUI/PauseMenu.queue_free()
	$GameUI/Splash.queue_free()
	$Sandbox.queue_free()
	
	var main_menu_instance = main_menu.instantiate()
	main_menu_instance.init_sandbox.connect(_on_init_sandbox)
	$UI.call_deferred("add_child", main_menu_instance)
	
	transition_instance.start_wait()
	await transition_instance.wait
	transition_instance.pop_out()
	await transition_instance.popped_out
