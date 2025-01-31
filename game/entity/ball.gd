class_name Ball
extends CharacterBody3D


signal camera_shake_request(direction)

@export var speed: float = 8.0

@export var scaffolding_break_particles: PackedScene
@export var timber_break_particles: PackedScene
@export var bricks_break_particles: PackedScene
@export var star_particles: PackedScene

var init = true
var tracking = false: set = _set_tracking
var direction_vector = Vector3(0, 0, 0)

func _set_tracking(new_tracking):
	tracking = new_tracking
	$PointerAnchor.set_visible(tracking)
	
	if tracking:
		$IdleParticles.set_visible(true)
		$IdleParticles.restart()
		$ActiveParticles.set_visible(false)
		$ActiveParticles.set_emitting(false)


func _process(_delta: float) -> void:
	if init:
		init = false
		$IdleParticles.set_visible(true)
		$IdleParticles.restart()
		$ActiveParticles.set_visible(false)
		$ActiveParticles.set_emitting(false)



func _physics_process(delta: float) -> void:
	position.z = 0.5
	velocity.z = 0
	
	var collision = move_and_collide(velocity * delta)

	if collision:
		var collider = collision.get_collider()
		
		if collider is GridMap:
			handle_brick_hit(collider, collision)
		
		camera_shake_request.emit(velocity)
		velocity = velocity.bounce(collision.get_normal())
	
	if tracking:
		var camera: Camera3D = get_viewport().get_camera_3d()
		var ball_screen_pos = camera.unproject_position(global_position)
		var cursor_position = get_viewport().get_mouse_position()
		var direction_vector_2d = (cursor_position - ball_screen_pos).normalized()
		direction_vector = Vector3(direction_vector_2d.x, -direction_vector_2d.y, 0)
		var angle = direction_vector_2d.angle_to(Vector2.RIGHT)
		var pointer_angle = Vector3(0.0, 0.0, angle)
		$PointerAnchor.set_rotation(pointer_angle)


func shoot():
	velocity = direction_vector.normalized() * speed
	$IdleParticles.set_visible(false)
	$IdleParticles.set_emitting(false)
	$ActiveParticles.set_visible(true)
	$ActiveParticles.restart()


func handle_brick_hit(gridmap: GridMap, collision: KinematicCollision3D) -> void:
	var collision_normal = collision.get_normal()
	var collision_position = collision.get_position() - collision_normal * 0.5
	var cell_position = global_to_map(gridmap, collision_position)
	var cell_item = gridmap.get_cell_item(cell_position)
	
	spawn_star_particles(collision_position, collision_normal)
	
	match cell_item:
		0: # Scaffolding
			gridmap.set_cell_item(cell_position, GridMap.INVALID_CELL_ITEM)
			spawn_break_particles(scaffolding_break_particles, gridmap, cell_position)
		1: # Timber
			gridmap.set_cell_item(cell_position, 2)
			spawn_break_particles(timber_break_particles, gridmap, cell_position)
		2: # Timber One Hit
			gridmap.set_cell_item(cell_position, GridMap.INVALID_CELL_ITEM)
			spawn_break_particles(timber_break_particles, gridmap, cell_position)
		3: # Bricks
			gridmap.set_cell_item(cell_position, 4)
			spawn_break_particles(bricks_break_particles, gridmap, cell_position)
		4: # Bricks One Hit
			gridmap.set_cell_item(cell_position, 5)
			spawn_break_particles(bricks_break_particles, gridmap, cell_position)
		5: # Bricks Two Hits
			gridmap.set_cell_item(cell_position, GridMap.INVALID_CELL_ITEM)
			spawn_break_particles(bricks_break_particles, gridmap, cell_position)
		6: # Girder
			pass


func global_to_map(gridmap: GridMap, global: Vector3) -> Vector3i:
	var local_position = gridmap.to_local(global)
	var cell_position = gridmap.local_to_map(local_position)
	return cell_position


func spawn_break_particles(break_particles: PackedScene, gridmap: GridMap, cell_position: Vector3i) -> void:
	var break_particles_instance = break_particles.instantiate()
	var local_spawn_position = gridmap.map_to_local(cell_position)
	var global_spawn_position = gridmap.to_global(local_spawn_position)
	break_particles_instance.set_global_transform(Transform3D(Basis(), global_spawn_position))
	call_deferred("add_sibling", break_particles_instance)


func spawn_star_particles(collision_position: Vector3, collision_normal: Vector3) -> void:
	var star_particles_instance = star_particles.instantiate()
	var process_material = star_particles_instance.get_node("GPUParticles3D").get_process_material()
	process_material.set_direction(collision_normal)
	star_particles_instance.set_global_transform(Transform3D(Basis(), collision_position))
	call_deferred("add_sibling", star_particles_instance)
