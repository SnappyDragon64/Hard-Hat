class_name Ball
extends CharacterBody3D


signal camera_shake_request(direction)
signal force_quit_aiming()

@export var speed: float = 16.0

@export var scaffolding_break_particles: PackedScene
@export var timber_break_particles: PackedScene
@export var bricks_break_particles: PackedScene
@export var star_particles: PackedScene

var init = true
var tracking = false: set = _set_tracking
var direction_vector := Vector3(1, 0, 0)
var dead := false

func _set_tracking(new_tracking):
	tracking = new_tracking
	$PointerAnchor.set_visible(tracking)
	
	if tracking:
		velocity = Vector3.ZERO
		$MeshInstance3D.set_rotation(Vector3.ZERO)
		$MeshInstance3D.set_scale(Vector3.ONE)
		$IdleParticles.set_visible(true)
		$IdleParticles.restart()
		$ActiveParticles.set_visible(false)
		$ActiveParticles.set_emitting(false)
		$PointerAnchor/RayCast3D.set_enabled(true)


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
		var collision_depth = collision.get_depth()
		var collision_normal = collision.get_normal()
		var collider = collision.get_collider()
		
		if collider.is_in_group("beam"):
			if tracking == true:
				force_quit_aiming.emit()
			
			global_position += collision_depth * collision_normal * 100.0
		
		velocity = velocity.bounce(collision_normal)
		update_squish()
		
		if not dead:
			var collision_position = collision.get_position()
			spawn_star_particles(collision_position, collision_normal)
			camera_shake_request.emit(velocity)
			AudioManager.play_sound(AudioRegistry.SFX_HIT, collision_position)
			
			if collider is GridMap and collider.is_in_group("breakable"):
				handle_brick_hit(collider, collision_normal, collision_position)
	
	if tracking:
		if InputManager.controller_mode:
			var controller_direction = Input.get_vector('aim_left', 'aim_right', 'aim_down', 'aim_up')
			
			if not controller_direction.is_zero_approx():
				var direction_vector_2d = controller_direction.normalized()
				direction_vector = Vector3(direction_vector_2d.x, direction_vector_2d.y, 0)
				var angle = controller_direction.angle()
				var pointer_angle = Vector3(0.0, 0.0, angle)
				$PointerAnchor.set_rotation(pointer_angle)
		else:
			var camera: Camera3D = get_viewport().get_camera_3d()
			var ball_screen_pos = camera.unproject_position(global_position)
			var cursor_position = get_viewport().get_mouse_position()
			var direction_vector_2d = (cursor_position - ball_screen_pos).normalized()
			direction_vector = Vector3(direction_vector_2d.x, -direction_vector_2d.y, 0)
			var angle = direction_vector_2d.angle_to(Vector2.RIGHT)
			var pointer_angle = Vector3(0.0, 0.0, angle)
			$PointerAnchor.set_rotation(pointer_angle)
		
		var mesh = $PointerAnchor/AssistMesh.get_mesh()
		var raycast = $PointerAnchor/RayCast3D
		raycast.force_raycast_update()
		if raycast.is_colliding():
			var collision_point = raycast.get_collision_point()
			var offset: Vector3 = global_position - collision_point
			var assist_len = offset.length()
			mesh.size.y = assist_len
			$PointerAnchor/AssistMesh.position.x = assist_len / 2.0
		else:
			mesh.size.y = 32.0
			$PointerAnchor/AssistMesh.position.x = 16.0


func kill():
	if not dead:
		$CollisionShape3D.disabled = true
		AudioManager.play_sound(AudioRegistry.SFX_FIZZLE)
		dead = true
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_callback(queue_free)


func start_tracking():
	tracking = true


func shoot():
	AudioManager.play_sound(AudioRegistry.SFX_STRIKE, global_position)
	velocity = direction_vector.normalized() * speed
	update_squish()
	$IdleParticles.set_visible(false)
	$IdleParticles.set_emitting(false)
	$ActiveParticles.set_visible(true)
	$ActiveParticles.restart()
	$PointerAnchor/RayCast3D.set_enabled(false)


func handle_brick_hit(gridmap: GridMap, collision_normal: Vector3, collision_position: Vector3) -> void:
	collision_position = collision_position - collision_normal * 0.5
	var cell_position = global_to_map(gridmap, collision_position)
	var cell_item = gridmap.get_cell_item(cell_position)
	
	match cell_item:
		0: # Scaffolding
			gridmap.set_cell_item(cell_position, GridMap.INVALID_CELL_ITEM)
			spawn_break_particles(scaffolding_break_particles, gridmap, cell_position)
			AudioManager.play_sound(AudioRegistry.SFX_BREAK, collision_position)
		1: # Timber
			var orientation = gridmap.get_cell_item_orientation(cell_position)
			gridmap.set_cell_item(cell_position, 2, orientation)
			spawn_break_particles(timber_break_particles, gridmap, cell_position)
		2: # Timber One Hit
			gridmap.set_cell_item(cell_position, GridMap.INVALID_CELL_ITEM)
			spawn_break_particles(timber_break_particles, gridmap, cell_position)
			AudioManager.play_sound(AudioRegistry.SFX_BREAK, collision_position)
		3: # Bricks
			var orientation = gridmap.get_cell_item_orientation(cell_position)
			gridmap.set_cell_item(cell_position, 4, orientation)
			spawn_break_particles(bricks_break_particles, gridmap, cell_position)
		4: # Bricks One Hit
			var orientation = gridmap.get_cell_item_orientation(cell_position)
			gridmap.set_cell_item(cell_position, 5, orientation)
			spawn_break_particles(bricks_break_particles, gridmap, cell_position)
		5: # Bricks Two Hits
			gridmap.set_cell_item(cell_position, GridMap.INVALID_CELL_ITEM)
			spawn_break_particles(bricks_break_particles, gridmap, cell_position)
			AudioManager.play_sound(AudioRegistry.SFX_BREAK, collision_position)
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


func update_squish():
	$MeshInstance3D.set_scale(Vector3(0.9, 1.1, 1.0))
	var velocity2d = Vector2(velocity.x, velocity.y).normalized()
	var squish_angle = -velocity2d.angle_to(Vector2.UP)
	$MeshInstance3D.set_rotation(Vector3(0.0, 0.0, squish_angle))
