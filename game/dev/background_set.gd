extends Node3D


func _ready():
	Signals.hide_main_menu_props.connect(_on_hide_main_menu_props)


func _on_hide_main_menu_props():
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(%MainMenuProps/Logo, "transparency", 1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(%MainMenuProps/Silhouette, "transparency", 1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
