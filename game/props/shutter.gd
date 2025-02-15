extends Node3D


@export var offset := Vector3.ZERO
@export var duration := 1.0


func _on_target_hit():
	$AnimatableBody3D.add_to_group("beam")
	var tween = get_tree().create_tween()
	tween.tween_property($RemoteTransform3D, "position", offset, duration)
	tween.tween_callback(_on_finish)


func _on_finish():
	$AnimatableBody3D.remove_from_group("beam")
