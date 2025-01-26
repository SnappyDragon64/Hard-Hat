extends Node3D


func _ready():
	$GPUParticles3D.set_one_shot(true)


func _on_timer_timeout():
	queue_free()
