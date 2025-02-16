extends Node


var rng = RandomNumberGenerator.new()

var ephemeral_player: PackedScene = preload("res://game/audio/ephemeral_player.tscn")
var ephemeral_player_3d: PackedScene = preload("res://game/audio/ephemeral_player_3d.tscn")


func play_sound(sound: AudioStream, position=null):
	var audio_stream_player
	
	if position:
		audio_stream_player = ephemeral_player_3d.instantiate()
		audio_stream_player.global_transform = Transform3D(Basis(), position)
	else:
		audio_stream_player = ephemeral_player.instantiate()
	
	var random_pitch = rng.randf_range(0.8, 1.2)
	
	audio_stream_player.set_stream(sound)
	audio_stream_player.set_pitch_scale(random_pitch)
	call_deferred("add_child", audio_stream_player)
	return audio_stream_player.finished
