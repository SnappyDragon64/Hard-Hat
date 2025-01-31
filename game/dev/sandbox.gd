extends Node3D


signal pause()
signal unpause()

enum GameState {DEFAULT, PAUSED, COUNTDOWN}

@export var player: PackedScene
@export var ball: PackedScene

var level: int = 0

var game_state: GameState = GameState.DEFAULT

var tripod_min_x := -9999.0
var tripod_max_x := 9999.0
var background_rotation_speed := 0.005

var shake_tween: Tween


func _ready():
	load_level(level)


func _physics_process(delta):
	if Input.is_action_just_pressed("pause"):
		match game_state:
			GameState.DEFAULT:
				game_state = GameState.PAUSED
				$Tripod.set_process_mode(PROCESS_MODE_DISABLED)
				$Level.set_process_mode(PROCESS_MODE_DISABLED)
				pause.emit()
			GameState.PAUSED:
				game_state = GameState.COUNTDOWN
				$UnpauseTimer.start()
				unpause.emit()
			GameState.COUNTDOWN:
				game_state = GameState.PAUSED
				$UnpauseTimer.stop()
				$Tripod.set_process_mode(PROCESS_MODE_DISABLED)
				$Level.set_process_mode(PROCESS_MODE_DISABLED)
				pause.emit()


func _on_unpause_timer_timeout():
	game_state = GameState.DEFAULT
	$Tripod.set_process_mode(PROCESS_MODE_INHERIT)
	$Level.set_process_mode(PROCESS_MODE_INHERIT)


func _on_player_x_update(new_x):
	var clamp_x = clampf(new_x, tripod_min_x, tripod_max_x)
	$Tripod.global_position.x = clamp_x
	%BackgroundCylinder.set_rotation(Vector3(0, clamp_x * background_rotation_speed, 0))


func _on_camera_shake_request(direction):
	direction = direction.normalized() * 0.05
	
	if shake_tween:
		shake_tween.kill()
	
	shake_tween = get_tree().create_tween()
	shake_tween.tween_property($Tripod/Camera3D, "position", direction, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	shake_tween.tween_property($Tripod/Camera3D, "position", Vector3.ZERO, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func load_level(id):
	for child in $Level.get_children():
		child.queue_free()
	
	var level_path = get_level_path(id)
	var level = load(level_path)
	var level_instance = level.instantiate()
	
	$Level.call_deferred("add_child", level_instance)
	call_deferred("setup_player", level_instance)


func setup_player(level_instance):
	var camera_anchors = level_instance.get_node("CameraAnchors")
	tripod_min_x = camera_anchors.get_node("Start").global_position.x
	tripod_max_x = camera_anchors.get_node("End").global_position.x
	
	var player_instance = player.instantiate()
	var ball_instance = ball.instantiate()
	
	var spawnpoints = level_instance.get_node("Spawnpoints")
	var player_spawnpoint = spawnpoints.get_node("Player")
	var player_spawn = player_spawnpoint.get_global_transform()
	player_spawn.origin.z = 0.5
	player_instance.set_global_transform(player_spawn)
	player_instance.x_update.connect(_on_player_x_update)
	player_instance.ball_reference = ball_instance
	
	var ball_spawnpoint = spawnpoints.get_node("Ball")
	var ball_spawn = ball_spawnpoint.get_global_transform()
	ball_spawn.origin.z = 0.5
	ball_instance.set_global_transform(ball_spawn)
	ball_instance.camera_shake_request.connect(_on_camera_shake_request)
	
	$Level.call_deferred("add_child", player_instance)
	$Level.call_deferred("add_child", ball_instance)


func get_level_path(id):
	return "res://game/level/%d.tscn" % id
