class_name Level
extends Node3D


var sandbox_reference: Sandbox
var player_reference: Player


func _on_body_entered_segment(body, segment_id: int, kill_ball=true):
	if body is Player:
		sandbox_reference.switch_segment(self, player_reference, segment_id, kill_ball)


func get_spawnpoint(segment_id: int) -> Transform3D:
	var spawnpoint_transform = Transform3D(Basis(), Vector3.ZERO)
	var segments = get_node("Segments")
	
	if segments:
		var segment = segments.get_node(str(segment_id))
		if segment:
			var spawnpoint = segment.get_node("Spawnpoint")
			spawnpoint_transform = spawnpoint.get_global_transform()
			spawnpoint_transform.origin.z = 0.5
	
	return spawnpoint_transform


func get_camera_anchors(segment_id) -> Vector2:
	var camera_anchor_min_max = Vector2(0.0, 0.0)
	var segments = get_node("Segments")
	
	if segments:
		var segment = segments.get_node(str(segment_id))
		if segment:
			var camera_anchors = segment.get_node_or_null("CameraAnchors")
			var start_anchor = camera_anchors.get_node("Start")
			var end_anchor = camera_anchors.get_node("End")
			
			if start_anchor:
				camera_anchor_min_max.x = start_anchor.global_position.x
			
			if end_anchor:
				camera_anchor_min_max.y = end_anchor.global_position.x
	
	return camera_anchor_min_max
