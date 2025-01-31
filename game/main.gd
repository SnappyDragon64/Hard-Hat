extends Node3D


@export var sandbox: PackedScene
@export var main_menu: PackedScene
@export var pause_menu: PackedScene


func _ready():
	var main_menu_instance = main_menu.instantiate()
	main_menu_instance.init_sandbox.connect(_on_init_sandbox)
	$UI.call_deferred("add_child", main_menu_instance)


func _on_init_sandbox():
	var sandbox_instance = sandbox.instantiate()
	var pause_menu_instance = pause_menu.instantiate()
	
	sandbox_instance.quit.connect(_on_quit_sandbox)
	
	sandbox_instance.init(pause_menu_instance.resume_pressed, pause_menu_instance.restart_pressed, pause_menu_instance.quit_pressed)
	pause_menu_instance.init(sandbox_instance.pause, sandbox_instance.unpause)
	
	$UI/MainMenu.queue_free()
	call_deferred("add_child", sandbox_instance)
	$UI.call_deferred("add_child", pause_menu_instance)


func _on_quit_sandbox():
	$UI/PauseMenu.queue_free()
	$Sandbox.queue_free()
	var main_menu_instance = main_menu.instantiate()
	main_menu_instance.init_sandbox.connect(_on_init_sandbox)
	$UI.call_deferred("add_child", main_menu_instance)
