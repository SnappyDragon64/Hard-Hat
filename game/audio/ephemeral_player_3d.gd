extends AudioStreamPlayer3D


func _ready():
	finished.connect(_on_finished)
	play()


func _on_finished():
	queue_free()
