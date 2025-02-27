extends Node3D


@export var offset := Vector3.ZERO
@export var duration := 1.0
@export var cooldown := 2.0


func _on_target_hit():
	AudioManager.play_sound(AudioRegistry.SFX_DING, global_position)
	var tween = get_tree().create_tween()
	tween.tween_property($RemoteTransform3D, "position", offset, duration)
	$RetractTimer.start(duration + cooldown)


func _on_retract_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property($RemoteTransform3D, "position", Vector3.ZERO, duration)
