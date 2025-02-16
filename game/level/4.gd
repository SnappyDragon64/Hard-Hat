extends Level


var segment_b_counter: int = 0


func _on_0_area_3d_body_entered(body):
	_on_body_entered_segment(body, 0)


func _on_1_area_3d_body_entered(body):
	_on_body_entered_segment(body, 1)


func _on_2_area_3d_body_entered(body):
	_on_body_entered_segment(body, 2)


func _on_3_area_3d_body_entered(body):
	_on_body_entered_segment(body, 3)


func _b_on_target_hit():
	segment_b_counter += 1
	_b_check_and_move_shutters()


func _b_check_and_move_shutters():
	if segment_b_counter == 3:
		$Shutter7._on_target_hit()
		$Shutter8._on_target_hit()
		$Shutter9._on_target_hit()


func _on_elevator_reached():
	SaveManager.update("level_4_completed", true)
	if SaveManager.check("outro_viewed"):
		sandbox_reference._on_quit()
	else:
		sandbox_reference._on_outro()
