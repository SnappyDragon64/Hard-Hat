extends Control


@export var texture_one: CompressedTexture2D
@export var texture_two: CompressedTexture2D
@export var texture_three: CompressedTexture2D


var unpause_tween: Tween


func init(pause_signal, unpause_signal):
	pause_signal.connect(_on_pause)
	unpause_signal.connect(_on_unpause)


func _on_pause():
	if unpause_tween:
		unpause_tween.kill()
		$Countdown.set_visible(false)
	
	$Filter.set_visible(true)
	$PauseLeft.set_visible(true)
	$Holder.set_visible(true)
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property($Filter, "color", Color(0.0, 0.17, 0.29, 0.60), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($PauseLeft, "position", Vector2(0, 0), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($PauseLeft, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($Holder/PauseRight, "position", Vector2(-720, -1080), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property($Holder/PauseRight, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_unpause():
	$Countdown.set_texture(texture_three)
	$Countdown.set_visible(true)
	unpause_tween = get_tree().create_tween().set_parallel()
	unpause_tween.tween_property($Filter, "color", Color(0.0, 0.17, 0.29, 0.0), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	unpause_tween.tween_property($PauseLeft, "position", Vector2(-500, -500), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	unpause_tween.tween_property($PauseLeft, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	unpause_tween.tween_property($Holder/PauseRight, "position", Vector2(-200, -400), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	unpause_tween.tween_property($Holder/PauseRight, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	unpause_tween.tween_callback(_update_countdown_to_two).set_delay(1)
	unpause_tween.tween_callback(_update_countdown_to_one).set_delay(2)
	unpause_tween.tween_callback(_hide_countdown).set_delay(3)
	unpause_tween.set_parallel(false)
	unpause_tween.tween_callback(_hide)
	


func _hide():
	$Filter.set_visible(false)
	$PauseLeft.set_visible(false)
	$Holder.set_visible(false)


func _update_countdown_to_two():
	$Countdown.set_texture(texture_two)


func _update_countdown_to_one():
	$Countdown.set_texture(texture_one)


func _hide_countdown():
	$Countdown.set_visible(false)
