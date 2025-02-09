extends Node3D


func _ready():
	for child in get_children():
		if child is GPUParticles3D:
			child.set_one_shot(true)
			child.restart()


func _on_timer_timeout():
	queue_free()
