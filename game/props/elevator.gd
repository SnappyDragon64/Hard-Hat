extends Node3D


signal reached()

var target_y := 10.0
var speed := 3.2
var startup_adjustment = 1.5
var startup_duration = 1.5


func _on_area_3d_body_entered(body):
	if body is Player:
		body.player_state = Player.PlayerState.ELEVATOR
		$RemoteTransform3D.set_remote_node(body.get_path())
		var new_position = position
		var startup_adjusted_position = position
		startup_adjusted_position.y = startup_adjusted_position.y + startup_adjustment
		var y_diff = target_y - new_position.y
		new_position.y = target_y
		var y_diff_adjusted = y_diff - startup_adjustment
		var duration = y_diff_adjusted / speed
		
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", startup_adjusted_position, startup_duration).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN).set_delay(1.0)
		tween.tween_property(self, "position", new_position, duration)
		tween.tween_callback(_on_tween_finish)


func _on_tween_finish():
	reached.emit()
