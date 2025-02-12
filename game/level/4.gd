extends Node3D


var segment_b_counter: int = 0


func _b_on_target_hit():
	segment_b_counter += 1
	_b_check_and_move_shutters()


func _b_check_and_move_shutters():
	if segment_b_counter == 3:
		$Shutter7._on_target_hit()
		$Shutter8._on_target_hit()
		$Shutter9._on_target_hit()
