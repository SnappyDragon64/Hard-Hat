extends Node3D


signal quit()
signal pause()
signal unpause()

enum GameState {DEFAULT, PAUSED, COUNTDOWN}

@export var player: PackedScene

@export var level_id: int = 1
var current_spawnpoint: int = 0

var game_state: GameState = GameState.DEFAULT

var tripod_min_x := -9999.0
var tripod_max_x := 9999.0
var background_rotation_speed := 0.005

var shake_tween: Tween


func _ready():
	load_level()


func _process(_delta):
	if Input.is_action_just_pressed("1"):
		load_level(1)
	if Input.is_action_just_pressed("2"):
		load_level(2)
	if Input.is_action_just_pressed("3"):
		load_level(3)
	if Input.is_action_just_pressed("4"):
		load_level(4)


func init(resume_signal, restart_signal, quit_signal):
	resume_signal.connect(_on_resume)
	restart_signal.connect(_on_restart)
	quit_signal.connect(_on_quit)


func _on_resume():
	game_state = GameState.COUNTDOWN
	$UnpauseTimer.start()
	unpause.emit()


func _on_restart():
	game_state = GameState.DEFAULT
	$Tripod.set_process_mode(PROCESS_MODE_INHERIT)
	$Level.set_process_mode(PROCESS_MODE_INHERIT)
	load_level()


func _on_quit():
	quit.emit()


func _physics_process(_delta):
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


func load_level(id=null):
	if id:
		level_id = id
	
	$Tripod.global_position.x = 0
	
	for child in $Level.get_children():
		child.queue_free()
	
	var level_path = get_level_path(level_id)
	var level = load(level_path)
	var level_instance = level.instantiate()
	
	$Level.call_deferred("add_child", level_instance)
	call_deferred("setup_player", level_instance)


func setup_player(level_instance):
	var camera_anchors = level_instance.get_node("CameraAnchors")
	tripod_min_x = camera_anchors.get_node("Start").global_position.x
	tripod_max_x = camera_anchors.get_node("End").global_position.x
	
	var player_instance: Player = player.instantiate()
	
	var spawnpoints = level_instance.get_node("Spawnpoints")
	var player_spawnpoint = spawnpoints.get_child(current_spawnpoint)
	var player_spawn = player_spawnpoint.get_global_transform()
	player_spawn.origin.z = 0.5
	player_instance.set_global_transform(player_spawn)
	
	player_instance.x_update.connect(_on_player_x_update)
	player_instance.camera_shake_request.connect(_on_camera_shake_request)
	player_instance.respawn.connect(load_level)
	
	$Level.call_deferred("add_child", player_instance)
	
	if level_instance.has_node("Ball"):
		var ball = level_instance.get_node("Ball")
		player_instance.ball_reference = ball
	


func get_level_path(id):
	return "res://game/level/%d.tscn" % id
