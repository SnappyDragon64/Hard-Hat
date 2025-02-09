class_name Player
extends CharacterBody3D


signal x_update(new_x)
signal camera_shake_request(direction)
signal respawn()

enum PlayerState {IDLE, RUN, JUMP, FALL, COYOTE_TIME, JUMP_QUEUED, AIM, STRIKE}

@export var ball: PackedScene
@export_group("Movement")
@export var SPEED := 5.0
@export var JUMP_SPEED := 4.5
@export var STRIKE_BOOST := 2.0
@export var GRAVITY := 1.0
@export var can_strike := true
@export var strike_queued := false

var player_state: PlayerState = PlayerState.IDLE: set = _set_player_state
var input_direction := 0.0
var player_direction := 1.0: set = _set_player_direction
var ball_reference: Ball
var progress_sprite_tween: Tween
var spin_tween: Tween
var flipped := false
var scripted := false


func kill():
	scripted = true
	velocity = Vector3(0.0, 10.0, 4.0)
	$DeathTimer.start()


func _set_player_state(new_player_state: PlayerState):
	match player_state:
		PlayerState.COYOTE_TIME:
			$CoyoteTimer.stop()
		PlayerState.JUMP_QUEUED:
			$JumpQueueTimer.stop()
		PlayerState.AIM:
			platform_floor_layers = 4294967295
			axis_lock_linear_y = false
			$AnimationHolder/AnimatedSprite3D.play()
	
	match new_player_state:
		PlayerState.IDLE:
			$AnimationHolder/AnimatedSprite3D.animation = 'idle'
		PlayerState.RUN:
			$AnimationHolder/AnimatedSprite3D.animation = 'run'
		PlayerState.JUMP:
			velocity.y = move_toward(JUMP_SPEED, 0, 0.1)
			$AnimationHolder/AnimatedSprite3D.animation = 'jump'
		PlayerState.COYOTE_TIME:
			$CoyoteTimer.start()
		PlayerState.JUMP_QUEUED:
			$JumpQueueTimer.start()
		PlayerState.AIM:
			platform_floor_layers = 0
			axis_lock_linear_y = true
			velocity = Vector3.ZERO
			$AnimationHolder/AnimatedSprite3D.animation = 'aim'
		PlayerState.STRIKE:
			$StrikeCooldown.start()
			can_strike = false
			velocity.y = STRIKE_BOOST
			$AnimationHolder/AnimatedSprite3D.animation = 'strike'
	
	player_state = new_player_state


func _set_player_direction(new_player_direction: float):
	player_direction = new_player_direction
	
	if flipped and player_direction == 1.0:
		_handle_flip(false, 0.0)
	elif not flipped and player_direction == -1.0:
		_handle_flip(true, PI)


func _handle_flip(flip_flag: bool, animation_angle: float):
	flipped = flip_flag
		
	if spin_tween:
		spin_tween.kill()
		
	spin_tween = get_tree().create_tween()
	spin_tween.tween_property($AnimationHolder, "rotation", Vector3(0, animation_angle, 0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _process(_delta) -> void:
	if ball_reference:
		var remaining_time = $BallTimer.get_time_left()
		%BallProgress.set_value(remaining_time)


func _physics_process(delta) -> void:
	if scripted:
		velocity.x = 0.0
		_handle_gravity(delta)
	else:
		input_direction = Input.get_axis("move_left", "move_right")
		
		if player_state != PlayerState.AIM:
			if input_direction > 0.0:
				player_direction = 1.0
			elif input_direction < 0.0:
				player_direction = -1.0
		
		if strike_queued and Input.is_action_pressed("strike"):
			_check_strike_condition()
		else:
			strike_queued = false
			$StrikeQueueTimer.stop()
			
		var collision = get_last_slide_collision()

		if collision:
			var collider = collision.get_collider()
			var collision_normal = collision.get_normal()
			
			if collider.is_in_group("spikes") and collision_normal.y > 0.0:
				kill()
		
		match player_state:
			PlayerState.IDLE:
				_idle_physics_process(delta)
			PlayerState.RUN:
				_run_physics_process(delta)
			PlayerState.JUMP:
				_jump_physics_process(delta)
			PlayerState.FALL:
				_fall_physics_process(delta)
			PlayerState.COYOTE_TIME:
				_coyote_time_physics_process(delta)
			PlayerState.JUMP_QUEUED:
				_jump_queued_physics_process(delta)
			PlayerState.AIM:
				_aim_physics_process(delta)
			PlayerState.STRIKE:
				_strike_physics_process(delta)
	
	move_and_slide()
	x_update.emit(global_position.x)


func _idle_physics_process(_delta) -> void:
	if input_direction:
		player_state = PlayerState.RUN
		
	_handle_jump()
	_handle_coyote_time()
	_handle_strike()


func _run_physics_process(_delta) -> void:
	if not input_direction:
		player_state = PlayerState.IDLE
		
	_handle_x_movement()
	_handle_jump()
	_handle_coyote_time()
	_handle_strike()


func _jump_physics_process(delta) -> void:
	_handle_gravity(delta)
	_handle_x_movement()
	
	if Input.is_action_just_released("jump"):
		velocity.y = 0.0
	
	if velocity.y <= 0.0:
		player_state = PlayerState.FALL
	
	_handle_strike()


func _fall_physics_process(delta) -> void:
	_handle_gravity(delta)
	_handle_x_movement()
	_handle_land()
	
	if Input.is_action_just_pressed("jump"):
		player_state = PlayerState.JUMP_QUEUED
	
	_handle_strike()


func _coyote_time_physics_process(delta) -> void:
	_handle_gravity(delta)
	_handle_x_movement()
	_handle_jump()
	_handle_land()
	_handle_strike()


func _jump_queued_physics_process(delta) -> void:
	_handle_gravity(delta)
	_handle_x_movement()
	_handle_land()
	
	if Input.is_action_pressed("jump"):
		if is_on_floor():
			player_state = PlayerState.JUMP
	else:
		player_state = PlayerState.FALL
	
	_handle_strike()


func _aim_physics_process(_delta) -> void:
	var flag = false
	var collision = get_last_slide_collision()
	
	if collision:
		var collider = collision.get_collider()
		var collision_normal = collision.get_normal()
		
		if collider.is_in_group("moving_platform"):
			if collision_normal.is_equal_approx(Vector3.UP):
				position.y += collision.get_depth()
			else:
				flag = true
	
	if flag or Input.is_action_just_released("strike") and ball_reference:
		player_state = PlayerState.STRIKE
		
		ball_reference.shoot()
		ball_reference.tracking = false
		_orient_with_respect_to_ball_direction()
		
		$BallTimer.start()


func _strike_physics_process(_delta) -> void:
	if is_on_floor():
		if input_direction:
			player_state = PlayerState.RUN
		else:
			player_state = PlayerState.IDLE
	else:
		player_state = PlayerState.FALL


func _handle_gravity(delta) -> void:
	velocity += get_gravity() * GRAVITY * delta


func _handle_x_movement() -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	velocity.x = input_dir * SPEED


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		player_state = PlayerState.JUMP


func _handle_land() -> void:
	if is_on_floor():
		if input_direction:
			player_state = PlayerState.RUN
		else:
			player_state = PlayerState.IDLE


func _handle_coyote_time() -> void:
	if not is_on_floor():
		player_state = PlayerState.COYOTE_TIME


func _handle_strike() -> void:
	if Input.is_action_just_pressed("strike") and can_strike:
		if ball_reference:
			strike_queued = true
			$StrikeQueueTimer.start()
			_check_strike_condition()

		else:
			$RayCast3D.set_target_position(Vector3(1.25 * player_direction, 0.0, 0.0))
			$RayCast3D.force_raycast_update()
			
			if not $RayCast3D.is_colliding():
				ball_reference = ball.instantiate()
				ball_reference.camera_shake_request.connect(_on_ball_camera_shake_request)
				ball_reference.force_quit_aiming.connect(_on_force_quit_aiming)
				var ball_position = global_position
				ball_position += Vector3(1.0 * player_direction, 1.0, 0.0)
				ball_reference.set_global_transform(Transform3D(Basis(), ball_position))
				call_deferred("add_sibling", ball_reference)
				$BallTimer.start()
				
				player_state = PlayerState.AIM
				ball_reference.start_tracking()
				
				if progress_sprite_tween:
					progress_sprite_tween.kill()
				
				progress_sprite_tween = get_tree().create_tween()
				progress_sprite_tween.tween_property($ProgressSprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)


func _check_strike_condition():
	if ball_reference:
		var ball_global_pos = ball_reference.get_global_position()
	
		var adjusted_pos = global_position + Vector3(0, 1, 0)
		var distance_squared = adjusted_pos.distance_squared_to(ball_global_pos)
		
		if distance_squared <= 6.0:
			strike_queued = false
			$StrikeQueueTimer.stop()
			player_state = PlayerState.AIM
			ball_reference.start_tracking()
			_orient_with_respect_to_ball()
			
			if progress_sprite_tween:
				progress_sprite_tween.kill()
			
			progress_sprite_tween = get_tree().create_tween()
			progress_sprite_tween.tween_property($ProgressSprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)


func _orient_with_respect_to_ball():
	var relative_ball_pos = ball_reference.get_global_position() - global_position
	
	if relative_ball_pos.x < -1.0 and player_direction == 1.0:
		player_direction = -1.0
	elif relative_ball_pos.x > 1.0 and player_direction == -1.0:
		player_direction = 1.0


func _orient_with_respect_to_ball_direction():
	var ball_direction = ball_reference.direction_vector
	
	if ball_direction.x < -0.16 and player_direction == 1.0:
		player_direction = -1.0
	elif ball_direction.x > 0.16 and player_direction == -1.0:
		player_direction = 1.0


func _on_coyote_timer_timeout():
	player_state = PlayerState.FALL


func _on_jump_queue_timer_timeout():
	player_state = PlayerState.FALL


func _on_ball_timer_timeout():
	ball_reference.kill()
	ball_reference = null
	
	if progress_sprite_tween:
		progress_sprite_tween.kill()
	
	progress_sprite_tween = get_tree().create_tween()
	progress_sprite_tween.tween_property($ProgressSprite, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.1)
	
	if player_state == PlayerState.AIM:
		if is_on_floor():
			if input_direction:
				player_state = PlayerState.RUN
			else:
				player_state = PlayerState.IDLE
		else:
			player_state = PlayerState.FALL


func _on_strike_cooldown_timeout() -> void:
	can_strike = true


func _on_strike_queue_timer_timeout() -> void:
	player_state = PlayerState.FALL


func _on_ball_camera_shake_request(direction):
	camera_shake_request.emit(direction)


func _on_force_quit_aiming():
	player_state = PlayerState.STRIKE
	
	ball_reference.shoot()
	ball_reference.tracking = false
	_orient_with_respect_to_ball_direction()
	
	$BallTimer.start()


func _on_death_timer_timeout():
	respawn.emit()
