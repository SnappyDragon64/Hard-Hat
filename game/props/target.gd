extends Node3D


signal hit()

@export var break_particles: PackedScene


func _ready():
	$AnimationPlayer.play("spin")


func _on_area_3d_body_entered(_body):
	hit.emit()
	$Area3D.set_deferred("monitoring", false)
	$Model.set_visible(false)
	$AnimationPlayer.stop()
	
	var break_particles_instance = break_particles.instantiate()
	var particles_pos = global_position + Vector3(0.5, 0.5, 0.5)
	break_particles_instance.set_global_transform(Transform3D(Basis(), particles_pos))
	add_sibling(break_particles_instance)
