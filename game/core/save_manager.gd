extends Node


@onready var _save_data := {
	"intro_viewed": false,
	"level_1_completed": false,
	"level_2_completed": false,
	"level_3_completed": false,
	"level_4_completed": false,
	"outro_viewed": false,
}


func _ready():
	_load()


func update(key, value):
	_save_data[str(key)] = value
	_save()


func check(key):
	return _save_data.get(str(key), false)


func _save():
	var save = FileAccess.open("user://save.dat", FileAccess.WRITE)
	var json_string = JSON.stringify(_save_data)
	save.store_line(json_string)
	save.close()


func _load():
	if not FileAccess.file_exists("user://save.dat"):
		_save()
	else:
		var save = FileAccess.open("user://save.dat", FileAccess.READ)
		var json_string = save.get_line()
		var parsed_json = JSON.parse_string(json_string)
		_save_data = parsed_json
		save.close()
