extends Node3D


signal started()
signal reached()

var target_y := 10.0
var speed := 4.0
var startup_adjustment := 1.25
var startup_duration := 1.0
var startup_delay := 0.5


func _on_area_3d_body_entered(body):
	if body is Player:
		started.emit()
		body.player_state = Player.PlayerState.ELEVATOR
		$RemoteTransform3D.set_remote_node(body.get_path())
		var new_position = position
		var startup_adjusted_position = position
		startup_adjusted_position.y = startup_adjusted_position.y + startup_adjustment
		var y_diff = target_y - new_position.y
		new_position.y = target_y
		var y_diff_adjusted = y_diff - startup_adjustment
		var duration = y_diff_adjusted / speed
		
		var tween = get_tree().create_tween().set_parallel()
		tween.tween_callback(_play_sound).set_delay(startup_delay)
		tween.tween_property(self, "position", startup_adjusted_position, startup_duration).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN).set_delay(startup_delay)
		tween.set_parallel(false)
		tween.tween_property(self, "position", new_position, duration)
		tween.tween_callback(_on_tween_finish)


func _play_sound():
	var finished = AudioManager.play_sound(AudioRegistry.SFX_ELEVATOR, global_position)
	finished.connect(_play_loop)


func _play_loop():
	$AudioStreamPlayer3D.play()


func _on_tween_finish():
	reached.emit()
