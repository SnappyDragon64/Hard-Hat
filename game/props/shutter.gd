extends Node3D


@export var target_position := Vector3.ZERO
@export var duration := 1.0


func _on_target_hit():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, duration)
