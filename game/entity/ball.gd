extends CharacterBody3D


@export var speed: float = 4.0

@export var scaffolding_break_particles: PackedScene
@export var timber_break_particles: PackedScene
@export var bricks_break_particles: PackedScene


func _ready() -> void:
	velocity = Vector3(1, 1, 0).normalized() * speed


func _physics_process(delta: float) -> void:
	position.z = 0.5
	velocity.z = 0
	
	var collision = move_and_collide(velocity * delta)

	if collision:
		var collider = collision.get_collider()
		
		if collider is GridMap:
			handle_brick_hit(collider, collision)
		
		velocity = velocity.bounce(collision.get_normal())


func handle_brick_hit(gridmap: GridMap, collision: KinematicCollision3D) -> void:
	var collision_position = collision.get_position() - collision.get_normal() * 0.5
	var cell_position = global_to_map(gridmap, collision_position)
	var cell_item = gridmap.get_cell_item(cell_position)
	
	match cell_item:
		0: # Scaffolding
			gridmap.set_cell_item(cell_position, GridMap.INVALID_CELL_ITEM)
			spawn_particles(scaffolding_break_particles, gridmap, cell_position)
		1: # Timber
			gridmap.set_cell_item(cell_position, 2)
			spawn_particles(timber_break_particles, gridmap, cell_position)
		2: # Timber One Hit
			gridmap.set_cell_item(cell_position, GridMap.INVALID_CELL_ITEM)
			spawn_particles(timber_break_particles, gridmap, cell_position)
		3: # Bricks
			gridmap.set_cell_item(cell_position, 4)
			spawn_particles(bricks_break_particles, gridmap, cell_position)
		4: # Bricks One Hit
			gridmap.set_cell_item(cell_position, 5)
			spawn_particles(bricks_break_particles, gridmap, cell_position)
		5: # Bricks Two Hits
			gridmap.set_cell_item(cell_position, GridMap.INVALID_CELL_ITEM)
			spawn_particles(bricks_break_particles, gridmap, cell_position)
		6: # Girder
			pass


func global_to_map(gridmap: GridMap, global: Vector3) -> Vector3i:
	var local_position = gridmap.to_local(global)
	var cell_position = gridmap.local_to_map(local_position)
	return cell_position


func spawn_particles(break_particles: PackedScene, gridmap: GridMap, cell_position: Vector3i) -> void:
	var break_particles_instance = break_particles.instantiate()
	var local_spawn_position = gridmap.map_to_local(cell_position)
	var global_spawn_position = gridmap.to_global(local_spawn_position)
	break_particles_instance.set_global_transform(Transform3D(Basis(), global_spawn_position))
	call_deferred("add_sibling", break_particles_instance)
