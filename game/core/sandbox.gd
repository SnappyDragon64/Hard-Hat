class_name Sandbox
extends Node3D


signal quit()
signal pause()
signal unpause()
signal reset_pause_menu()


var transition_instance

enum GameState {DEFAULT, PAUSED, COUNTDOWN}

@export var player: PackedScene

@export var level_id: int = 1
var current_segment: int = 0
var ball_segment: int = 0

var game_state: GameState = GameState.DEFAULT

var tripod_min_x := -9999.0
var tripod_max_x := 9999.0
var background_rotation_speed := 0.005

var shake_tween: Tween
var audio_tween: Tween
var transition_flag := true

var splash_instance: Splash


func _ready():
	change_level(level_id, false, true)


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
	
	if audio_tween:
		audio_tween.kill()
				
		audio_tween = get_tree().create_tween()
		audio_tween.tween_property($AudioStreamPlayer, "volume_db", -20.0, 2.25).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)



func _on_restart():
	game_state = GameState.DEFAULT
	$Tripod.set_process_mode(PROCESS_MODE_INHERIT)
	$Level.set_process_mode(PROCESS_MODE_INHERIT)
	load_level()


func _on_quit():
	transition_instance.pop_in()
	await transition_instance.popped_in
	quit.emit()


func _physics_process(_delta):
	if not transition_flag and Input.is_action_just_pressed("pause"):
		match game_state:
			GameState.DEFAULT:
				splash_instance.kill_if_tween()
				splash_instance.hide_splash()
				game_state = GameState.PAUSED
				$Tripod.set_process_mode(PROCESS_MODE_DISABLED)
				$Level.set_process_mode(PROCESS_MODE_DISABLED)
				pause.emit()
				
				if audio_tween:
					audio_tween.kill()
				
				audio_tween = get_tree().create_tween()
				audio_tween.tween_property($AudioStreamPlayer, "volume_db", -50.0, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
			GameState.PAUSED:
				game_state = GameState.COUNTDOWN
				$UnpauseTimer.start()
				unpause.emit()
				
				if audio_tween:
					audio_tween.kill()
				
				audio_tween = get_tree().create_tween()
				audio_tween.tween_property($AudioStreamPlayer, "volume_db", -20.0, 2.25).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
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
	if new_x < tripod_min_x or new_x > tripod_max_x:
		new_x = clampf(new_x, tripod_min_x, tripod_max_x)
		new_x = move_toward($Tripod.global_position.x, new_x, 0.5)
	else:
		new_x = clampf(new_x, tripod_min_x, tripod_max_x)
		
	$Tripod.global_position.x = new_x
	%BackgroundCylinder.set_rotation(Vector3(0, new_x * background_rotation_speed, 0))


func _on_camera_shake_request(direction):
	direction = direction.normalized() * 0.05
	
	if shake_tween:
		shake_tween.kill()
	
	shake_tween = get_tree().create_tween()
	shake_tween.tween_property($Tripod/Camera3D, "position", direction, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	shake_tween.tween_property($Tripod/Camera3D, "position", Vector3.ZERO, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func change_level(id, flag=true, splash_flag=false):
	current_segment = 0
	ball_segment = 0
	load_level(id, flag, splash_flag)


func load_level(id=null, flag=true, splash_flag=false):
	if flag:
		if audio_tween:
			audio_tween.kill()
	
		audio_tween = get_tree().create_tween()
		audio_tween.tween_property($AudioStreamPlayer, "volume_db", -60.0, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		audio_tween.tween_callback(_on_audio_tween)
	
		transition_instance.pop_in()
		await transition_instance.popped_in
		reset_pause_menu.emit()
	
	if id:
		level_id = id
	
	if splash_instance:
		if splash_flag:
			splash_instance.setup_level_splash(level_id)
		else:
			splash_instance.hide_splash()
	
	$Tripod.global_position.x = 0
	
	for child in $Level.get_children():
		child.queue_free()
	
	var level_path = get_level_path(level_id)
	var level = load(level_path)
	var level_instance: Level = level.instantiate()
	level_instance.sandbox_reference = self
	
	$Level.call_deferred("add_child", level_instance)
	await level_instance.ready
	call_deferred("setup_player", level_instance, splash_flag)


func setup_player(level_instance: Level, splash_flag=false):
	var camera_anchors: Vector2 = level_instance.get_camera_anchors(current_segment)
	set_tripod_values(camera_anchors.x, camera_anchors.y, true)
	
	var player_instance: Player = player.instantiate()
	level_instance.player_reference = player_instance
	
	var spawnpoint = level_instance.get_spawnpoint(current_segment)
	player_instance.set_global_transform(spawnpoint)
	
	player_instance.x_update.connect(_on_player_x_update)
	player_instance.camera_shake_request.connect(_on_camera_shake_request)
	player_instance.respawn.connect(load_level)
	
	$Level.call_deferred("add_child", player_instance)
	
	player_instance.ball_reference = level_instance.get_node_or_null("Ball")
	
	await player_instance.ready
	$Tripod.set_process_mode(PROCESS_MODE_DISABLED)
	$Level.set_process_mode(PROCESS_MODE_DISABLED)
	transition_instance.start_wait()
	await transition_instance.wait
	
	$AudioStreamPlayer.set_volume_db(-60.0)
	$AudioStreamPlayer.play(0.0)
	
	if audio_tween:
		audio_tween.kill()
	
	audio_tween = get_tree().create_tween()
	audio_tween.tween_property($AudioStreamPlayer, "volume_db", -20.0, 0.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	
	transition_instance.pop_out()
	$Tripod.set_process_mode(PROCESS_MODE_INHERIT)
	$Level.set_process_mode(PROCESS_MODE_INHERIT)
	
	await transition_instance.popped_out
	transition_flag = false
	
	if splash_instance and splash_flag:
		splash_instance.queue_fade_out()


func set_tripod_values(min_x, max_x, force_update=false):
	tripod_min_x = min_x
	tripod_max_x = max_x
	
	if force_update:
		$Tripod.global_position.x = min_x


func get_level_path(id):
	return "res://game/level/%d.tscn" % id


func switch_segment(level_instance: Level, player_instance: Player, segment_id, kill_ball):
	if segment_id > current_segment:
		current_segment = segment_id
	
	if kill_ball and segment_id != ball_segment:
		player_instance.kill_ball()
	
	ball_segment = segment_id
	
	var camera_anchors: Vector2 = level_instance.get_camera_anchors(segment_id)
	set_tripod_values(camera_anchors.x, camera_anchors.y)


func _on_audio_tween():
	$AudioStreamPlayer.stop()
