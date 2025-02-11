extends Node3D


func _ready() -> void:
	$Path3D/AnimationPlayer.play("move")
	$Path3D2/AnimationPlayer.play("move")
	$Path3D3/AnimationPlayer.play("move")
	$Path3D4/AnimationPlayer.play("move")
	$Path3D5/AnimationPlayer.play("move")
	$Path3D7/AnimationPlayer.play("move")
	$Path3D6/AnimationPlayer.play("move")
	$Path3D8/AnimationPlayer.play("move")
	$Path3D9/AnimationPlayer.play("move")
	$Path3D10/AnimationPlayer.play("move")
	$Path3D11/AnimationPlayer.play("move")

func _on_target_hit() -> void:
	pass # Replace with function body.
