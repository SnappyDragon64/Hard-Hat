extends CharacterBody3D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var GRAVITY = 1.0

var can_jump = false
var coyote = false
var jump_queued = false


func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * GRAVITY * delta
		
		if not coyote:
			coyote = true
			$CoyoteTimer.start()

	if is_on_floor():
		can_jump = true
		coyote = false
	
	if Input.is_action_just_pressed("jump"):
		if can_jump:
			can_jump = false
			velocity.y = JUMP_VELOCITY
		else:
			jump_queued = true
			$JumpQueueTimer.start()
	
	if Input.is_action_pressed("jump") and can_jump and jump_queued:
		can_jump = false
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released("jump") and velocity.y > 0.0:
		velocity.y = 0.0

	var input_dir = Input.get_axis("move_left", "move_right")
	if input_dir:
		velocity.x = input_dir * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_coyote_timer_timeout():
	can_jump = false


func _on_jump_queue_timer_timeout():
	jump_queued = false
