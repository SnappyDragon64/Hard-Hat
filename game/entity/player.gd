class_name Player
extends CharacterBody3D


enum PlayerState {IDLE, RUN, JUMP, FALL, COYOTE_TIME, JUMP_QUEUED, AIM, STRIKE}

@export_group("Movement")
@export var SPEED := 5.0
@export var JUMP_SPEED := 4.5
@export var GRAVITY := 1.0

var player_state: PlayerState = PlayerState.IDLE: set = _set_player_state
var input_direction := 0.0
var player_direction := 1.0
var ball_reference: Ball

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
	
	player_state = new_player_state


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


func _aim_physics_process(delta) -> void:
	if Input.is_action_just_released("strike"):
		player_state = PlayerState.STRIKE
		
		if ball_reference:
			ball_reference.shoot()
			ball_reference.tracking = false


func _strike_physics_process(delta) -> void:
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
		
		if signf(relative_x) == player_direction:
			player_state = PlayerState.AIM
			ball_reference.velocity = Vector3.ZERO
			ball_reference.tracking = true


func _on_coyote_timer_timeout():
	player_state = PlayerState.FALL


func _on_jump_queue_timer_timeout():
	player_state = PlayerState.FALL


func _on_ball_area_3d_body_entered(body):
	if body is Ball:
		ball_reference = body


func _on_ball_area_3d_body_exited(body):
	if body is Ball:
		ball_reference = null
