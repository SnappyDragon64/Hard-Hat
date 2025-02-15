extends Control


signal finished()

var current_panel: int = 0
var max_panels: int = 6
var lock := true
var done := false


func _input(event: InputEvent):
	if event.is_pressed() and not lock:
		current_panel += 1
		
		if current_panel < max_panels:
			load_next_panel()
			on_panel_load(current_panel)
		elif not done:
			done = true
			on_finish()


func load_next_panel():
	var panel = $CenterContainer.get_child(current_panel)
	lock = true
	var tween = get_tree().create_tween()
	tween.tween_property(panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_unlock)


func on_panel_load(_panel_id):
	pass


func on_finish():
	finished.emit()


func _unlock():
	lock = false
