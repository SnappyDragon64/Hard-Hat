extends Node3D


@export var player: PackedScene
@export var ball: PackedScene


var initial_level: int = 0


func _ready():
	load_level(initial_level)


func load_level(id):
	for child in $Level.get_children():
		child.queue_free()
	
	var level_path = get_level_path(id)
	var level = load(level_path)
	var level_instance = level.instantiate()
	
	var spawnpoints = level_instance.get_node("Spawnpoints")
	
	$Level.call_deferred("add_child", level_instance)
	call_deferred("setup_player", spawnpoints)


func setup_player(spawnpoints):
	var player_instance = player.instantiate()
	var ball_instance = ball.instantiate()
	
	var player_spawnpoint = spawnpoints.get_node("Player")
	var player_spawn = player_spawnpoint.get_global_transform()
	player_spawn.origin.z = 0.5
	player_instance.set_global_transform(player_spawn)
	
	var ball_spawnpoint = spawnpoints.get_node("Ball")
	var ball_spawn = ball_spawnpoint.get_global_transform()
	ball_spawn.origin.z = 0.5
	ball_instance.set_global_transform(ball_spawn)
	
	$Level.call_deferred("add_child", player_instance)
	$Level.call_deferred("add_child", ball_instance)


func get_level_path(id):
	return "res://game/level/%d.tscn" % id
