extends AnimatedSprite3D

var peak_sprite
var jump_sprite
var idle_sprite
var run_sprite
var aim_sprite
var strike_sprite


func _ready() -> void:
	play("idle")
	peak_sprite = preload('res://assets/sprite/game/player/Peak.png')
	jump_sprite = preload('res://assets/sprite/game/player/Jump.png')
	idle_sprite = preload('res://assets/sprite/game/player/Idle.png')
	run_sprite = preload('res://assets/sprite/game/player/Run.png')
	aim_sprite = preload('res://assets/sprite/game/player/Aim.png')
	strike_sprite = preload('res://assets/sprite/game/player/Strike.png')
	

	position = Vector3(0.305, 1.315, 0)
	material_overlay.set_shader_parameter("sprite_texture",  idle_sprite)


func _on_animation_finished() -> void:
	if animation == 'strike':
		animation = 'peak'
	elif animation == 'jump':
		animation = 'peak'
	if animation != 'aim':
		play()


func _on_animation_changed() -> void:
	if animation == 'fall':
		position = Vector3(0.460, 1.095, 0)
		
	elif animation == 'peak':
		position = Vector3(0.295, 0.975, 0)
		material_overlay.set_shader_parameter("sprite_texture",  peak_sprite)
		
	elif animation == 'jump':
		position = Vector3(0.615, 1.185, 0)
		material_overlay.set_shader_parameter("sprite_texture",  jump_sprite)
		
	elif animation == 'idle':
		position = Vector3(0.305, 1.315, 0)
		material_overlay.set_shader_parameter("sprite_texture",  idle_sprite)
		
	elif animation == 'run':
		position = Vector3(0.385, 1.435, 0)
		material_overlay.set_shader_parameter("sprite_texture",  run_sprite)
	
	elif animation == 'aim':
		position = Vector3(0, 1.4, 0)
		material_overlay.set_shader_parameter("sprite_texture", aim_sprite)
	
	elif animation == 'strike':
		position = Vector3(0, 1.4, 0)
		material_overlay.set_shader_parameter("sprite_texture", strike_sprite)
