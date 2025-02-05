class_name Player
extends CharacterBody3D


signal x_update(new_x)

enum PlayerState {IDLE, RUN, JUMP, FALL, COYOTE_TIME, JUMP_QUEUED, AIM, STRIKE}

@export var ball: PackedScene
@export_group("Movement")
@export var SPEED := 5.0
@export var JUMP_SPEED := 4.5
@export var STRIKE_BOOST := 2.0
@export var GRAVITY := 1.0

var player_state: PlayerState = PlayerState.IDLE: set = _set_player_state
var input_direction := 0.0
var player_direction := 1.0
var ball_reference: Ball
var progress_sprite_tween: Tween

func _set_player_state(new_player_state: PlayerState):
	match player_state:
		PlayerState.COYOTE_TIME:
			$CoyoteTimer.stop()
		PlayerState.JUMP_QUEUED:
			$JumpQueueTimer.stop()
	
	match new_player_state:
		PlayerState.JUMP:
			velocity.y = JUMP_SPEED
		PlayerState.COYOTE_TIME:
			$CoyoteTimer.start()
		PlayerState.JUMP_QUEUED:
			$JumpQueueTimer.start()
		PlayerState.AIM:
			velocity = Vector3.ZERO
		PlayerState.STRIKE:
			velocity.y = STRIKE_BOOST
	
	player_state = new_player_state


func _process(_delta) -> void:
	if ball_reference:
		var remaining_time = $BallTimer.get_time_left()
		%BallProgress.set_value(remaining_time)


func _physics_process(delta) -> void:
	input_direction = Input.get_axis("move_left", "move_right")
	
	if input_direction > 0.0:
		player_direction = 1.0
	elif input_direction < 0.0:
		player_direction = -1.0
	
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
	
	#print_debug("Player State: ", PlayerState.keys()[player_state])
	
	move_and_slide()
	x_update.emit(global_position.x)


func _idle_physics_process(_delta) -> void:
	if input_direction:
		player_state = PlayerState.RUN
		
	_handle_jump()
	_handle_coyote_time()
	_handle_strike()
	_handle_place_ball()


func _run_physics_process(_delta) -> void:
	if not input_direction:
		player_state = PlayerState.IDLE
		
	_handle_x_movement()
	_handle_jump()
	_handle_coyote_time()
	_handle_strike()
	_handle_place_ball()


func _jump_physics_process(delta) -> void:
	_handle_gravity(delta)
	_handle_x_movement()
	
	if Input.is_action_just_released("jump"):
		velocity.y = 0.0
	
	if velocity.y <= 0.0:
		player_state = PlayerState.FALL
	
	_handle_strike()
	_handle_place_ball()


func _fall_physics_process(delta) -> void:
	_handle_gravity(delta)
	_handle_x_movement()
	_handle_land()
	
	if Input.is_action_just_pressed("jump"):
		player_state = PlayerState.JUMP_QUEUED
	
	_handle_strike()
	_handle_place_ball()


func _coyote_time_physics_process(delta) -> void:
	_handle_gravity(delta)
	_handle_x_movement()
	_handle_jump()
	_handle_land()
	_handle_strike()
	_handle_place_ball()


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
	_handle_place_ball()


func _aim_physics_process(_delta) -> void:
	if Input.is_action_just_released("strike") and ball_reference:
		player_state = PlayerState.STRIKE
		
		ball_reference.shoot()
		ball_reference.tracking = false
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
	if Input.is_action_just_pressed("strike") and ball_reference:
		var ball_global_pos = ball_reference.get_global_position()
		var relative_x = ball_global_pos.x - global_position.x
		
		var adjusted_pos = global_position + Vector3(0, 1, 0)
		var distance_squared = adjusted_pos.distance_squared_to(ball_global_pos)
		
		if distance_squared <= 4.0 and signf(relative_x) == player_direction:
			player_state = PlayerState.AIM
			ball_reference.start_tracking()
			
			if progress_sprite_tween:
				progress_sprite_tween.kill()
			
			%BallProgress.set_value(10.0)
			progress_sprite_tween = get_tree().create_tween()
			progress_sprite_tween.tween_property($ProgressSprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)



func _handle_place_ball() -> void:
	if Input.is_action_just_pressed("place_ball") and not ball_reference:
		ball_reference = ball.instantiate()
		var ball_position = global_position
		ball_position += Vector3(1.0 * player_direction, 1.0, 0.0)
		ball_reference.set_global_transform(Transform3D(Basis(), ball_position))
		call_deferred("add_sibling", ball_reference)
		


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
