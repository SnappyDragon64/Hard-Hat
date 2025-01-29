extends Node3D


@export var sandbox: PackedScene


func _ready():
	Signals.init_sandbox.connect(_on_init_sandbox)


func _on_init_sandbox():
	var sandbox_instance = sandbox.instantiate()
	call_deferred("add_child", sandbox_instance)
	$UI/MainMenu.queue_free()
