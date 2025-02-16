extends CharacterBody3D


var player: Player


func _physics_process(_delta):
	if player and not player.player_state == Player.PlayerState.AIM and player.is_on_floor():
		velocity.x = 2.0
	else:
		velocity.x = 0.0
	
	move_and_slide()


func _on_area_3d_body_entered(body):
	if body is Player:
		AudioManager.play_sound(AudioRegistry.SFX_DING, global_position)
		player = body


func _on_area_3d_body_exited(body):
	if body is Player:
		player = null
