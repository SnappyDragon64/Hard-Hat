extends Node3D


var twirl_tween: Tween
var silhouette_texture: Texture2D


func hide_main_menu_props():
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(%MainMenuProps/Logo, "transparency", 1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(%MainMenuProps/Silhouette, "transparency", 1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func twirl_silhouette(next_silhouette):
	silhouette_texture = next_silhouette
	
	if twirl_tween:
		twirl_tween.kill()
		reset_silhouette()
	
	var target_angle_radians = deg_to_rad(384.0)
	var target_rotation = Vector3(0.0, target_angle_radians, 0.0)
	
	twirl_tween = get_tree().create_tween().set_parallel(true)
	twirl_tween.tween_callback(update_silhouette).set_delay(0.27)
	twirl_tween.tween_property($MainMenuProps/Silhouette, "rotation", target_rotation, 0.5).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_IN_OUT)
	twirl_tween.set_parallel(false)
	twirl_tween.tween_callback(reset_silhouette)


func update_silhouette():
	%MainMenuProps/Silhouette.set_texture(silhouette_texture)
	%MainMenuProps/Silhouette.material_override.set_shader_parameter("sprite_texture", silhouette_texture)


func reset_silhouette():
	var target_angle_radians = deg_to_rad(24.0)
	var target_rotation = Vector3(0.0, target_angle_radians, 0.0)
	$MainMenuProps/Silhouette.set_rotation(target_rotation)
