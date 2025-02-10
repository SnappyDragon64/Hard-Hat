extends Target


@export var respawn_time := 4.0


func _ready():
	super._ready()
	hit.connect(_on_hit)


func _on_hit():
	$RespawnTimer.start(respawn_time)


func _on_respawn_timer_timeout():
	$Area3D.set_deferred("monitoring", true)
	$Model.set_visible(true)
	$AnimationPlayer.play("spin")
