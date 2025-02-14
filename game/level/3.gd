extends Level


func _on_0_area_3d_body_entered(body):
	_on_body_entered_segment(body, 0)


func _on_1_area_3d_body_entered(body):
	_on_body_entered_segment(body, 1)


func _on_2_area_3d_body_entered(body):
	_on_body_entered_segment(body, 2)


func _on_3_area_3d_body_entered(body):
	_on_body_entered_segment(body, 3)


func _on_elevator_reached():
	sandbox_reference.change_level(4, true, true)
