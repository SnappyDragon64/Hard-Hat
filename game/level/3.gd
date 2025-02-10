extends Node3D


func _ready():
	$Path3D/AnimationPlayer.play("move")
	$Path3D2/AnimationPlayer.play("move")
	$Path3D3/AnimationPlayer.play("move")
	$Path3D4/AnimationPlayer.play("move")
	$Path3D5/AnimationPlayer.play("move")
	$Path3D7/AnimationPlayer.play("move")

func _on_target_hit() -> void:
	pass # Replace with function body.
