extends CharacterBody3D


enum MovementState {IDLE, RUN, JUMP, FALL, COYOTE_TIME, JUMP_QUEUED}

@export_group("Movement")
@export var SPEED := 5.0
@export var JUMP_SPEED := 4.5
@export var GRAVITY := 1.0

var movement_state: MovementState = MovementState.IDLE: set = _set_movement_state
var input_direction := 0.0


func _set_movement_state(new_movement_state: MovementState):
	match movement_state:
		MovementState.COYOTE_TIME:
			$CoyoteTimer.stop()
		MovementState.JUMP_QUEUED:
			$JumpQueueTimer.stop()
	
	match new_movement_state:
		MovementState.JUMP:
			velocity.y = JUMP_SPEED
		MovementState.COYOTE_TIME:
			$CoyoteTimer.start()
		MovementState.JUMP_QUEUED:
			$JumpQueueTimer.start()
	
	movement_state = new_movement_state


func _physics_process(delta) -> void:
	input_direction = Input.get_axis("move_left", "move_right")
	
	match movement_state:
		MovementState.IDLE:
			_idle_physics_process(delta)
		MovementState.RUN:
			_run_physics_process(delta)
		MovementState.JUMP:
			_jump_physics_process(delta)
		MovementState.FALL:
			_fall_physics_process(delta)
		MovementState.COYOTE_TIME:
			_coyote_time_physics_process(delta)
		MovementState.JUMP_QUEUED:
			_jump_queued_physics_process(delta)
	
	#print_debug("Movement State: ", MovementState.keys()[movement_state])
	
	move_and_slide()


func _idle_physics_process(delta) -> void:
	if input_direction:
		movement_state = MovementState.RUN
	
	_handle_jump()
	_handle_coyote_time()

func _run_physics_process(delta) -> void:
	if not input_direction:
		movement_state = MovementState.IDLE
	
	_handle_x_movement()
	_handle_jump()
	_handle_coyote_time()


func _jump_physics_process(delta) -> void:
	_handle_gravity(delta)
	_handle_x_movement()
	
	if velocity.y <= 0.0:
		movement_state = MovementState.FALL


func _fall_physics_process(delta) -> void:
	_handle_gravity(delta)
	_handle_x_movement()
	_handle_land()
	
	if Input.is_action_just_pressed("jump"):
		movement_state = MovementState.JUMP_QUEUED


func _coyote_time_physics_process(delta) -> void:
	_handle_gravity(delta)
	_handle_x_movement()
	_handle_jump()
	_handle_land()


func _jump_queued_physics_process(delta) -> void:
	_handle_gravity(delta)
	_handle_x_movement()
	_handle_land()
	
	if Input.is_action_pressed("jump"):
		if is_on_floor():
			movement_state = MovementState.JUMP
	else:
		movement_state = MovementState.FALL


func _handle_gravity(delta) -> void:
	velocity += get_gravity() * GRAVITY * delta


func _handle_x_movement() -> void:
	var input_dir = Input.get_axis("move_left", "move_right")
	velocity.x = input_dir * SPEED


func _handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		movement_state = MovementState.JUMP


func _handle_land() -> void:
	if is_on_floor():
		if input_direction:
			movement_state = MovementState.RUN
		else:
			movement_state = MovementState.IDLE


func _handle_coyote_time() -> void:
	if not is_on_floor():
		movement_state = MovementState.COYOTE_TIME


func _on_coyote_timer_timeout():
	movement_state = MovementState.FALL


func _on_jump_queue_timer_timeout():
	movement_state = MovementState.FALL
