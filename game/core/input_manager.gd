extends Node

var controller_mode := false

func _input(event):
	if Input.is_action_just_pressed("toggle_controller"):
		controller_mode = !controller_mode
		
		if controller_mode:
			Input.set_mouse_mode(1)
		else:
			Input.set_mouse_mode(0)
