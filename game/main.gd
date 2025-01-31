extends Node3D


@export var sandbox: PackedScene
@export var main_menu: PackedScene


func _ready():
	var main_menu_instance = main_menu.instantiate()
	main_menu_instance.init_sandbox.connect(_on_init_sandbox)
	$UI.call_deferred("add_child", main_menu_instance)


func _on_init_sandbox():
	var sandbox_instance = sandbox.instantiate()
	call_deferred("add_child", sandbox_instance)
	$UI/MainMenu.queue_free()
