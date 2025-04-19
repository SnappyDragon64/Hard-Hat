extends AnimatedSprite3D

@export_group("Idle")
@export var idle_offset: Vector3
@export var idle_sprite: Texture2D

@export_group("Run")
@export var run_offset: Vector3
@export var run_sprite: Texture2D

@export_group("Jump")
@export var jump_offset: Vector3
@export var jump_sprite: Texture2D

@export_group("Peak")
@export var peak_offset: Vector3
@export var peak_sprite: Texture2D

@export_group("Fall")
@export var fall_offset: Vector3
@export var fall_sprite: Texture2D

@export_group("Slide")
@export var slide_offset: Vector3
@export var slide_sprite: Texture2D

@export_group("Aim")
@export var aim_offset: Vector3
@export var aim_sprite: Texture2D

@export_group("Strike")
@export var strike_offset: Vector3
@export var strike_sprite: Texture2D

@export_group("Death")
@export var death_offset: Vector3
@export var death_sprite: Texture2D


func _ready() -> void:
	play("idle")


func _on_animation_finished() -> void:
	if animation == "jump" or animation == "strike":
		animation = "peak"
	
	if animation != "aim":
		play()


func _on_animation_changed() -> void:
	match animation:
		"idle":
			set_offset_and_sprite(idle_offset, idle_sprite)
		"run":
			set_offset_and_sprite(run_offset, run_sprite)
		"jump":
			set_offset_and_sprite(jump_offset, jump_sprite)
		"peak":
			set_offset_and_sprite(peak_offset, peak_sprite)
		"fall":
			set_offset_and_sprite(fall_offset, fall_sprite)
		"slide":
			set_offset_and_sprite(slide_offset, slide_sprite)
		"aim":
			set_offset_and_sprite(aim_offset, aim_sprite)
		"strike":
			set_offset_and_sprite(strike_offset, strike_sprite)
		"death":
			set_offset_and_sprite(death_offset, death_sprite)


func set_offset_and_sprite(position_offset: Vector3, sprite: Texture2D):
	position = position_offset
	material_overlay.set_shader_parameter("sprite_texture",  sprite)
