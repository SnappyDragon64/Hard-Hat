extends Node3D


var tween: Tween


func _on_area_3d_body_entered(body):
	if body is Player:
		body.is_on_spring = true
		
		if tween:
			tween.kill()
		
		tween = get_tree().create_tween()
		tween.tween_property($Holder, "scale", Vector3(1.0, 0.8, 1.0), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func _on_area_3d_body_exited(body):
	if body is Player:
		body.is_on_spring = false
		
		if tween:
			tween.kill()
		
		tween = get_tree().create_tween()
		tween.tween_property($Holder, "scale", Vector3(1.0, 1.0, 1.0), 0.1).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN)
