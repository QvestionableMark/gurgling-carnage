class_name Game
extends Node2D

var persistent_data = {
	"checkpoint": 0,
	"timer": 0
}
signal persistent_data_loaded(new_data)

@export var stages : Array[String]
var current_stage : Stage

func _ready() -> void:
	load_persistent_data()
	#temp until buttons work
	if persistent_data["checkpoint"] != -1:
		load_stage(stages[persistent_data["checkpoint"]])

func load_stage(stage_to_load):
	if current_stage:
		current_stage.queue_free()
	persistent_data["checkpoint"] = stages.find(stage_to_load)
	save_persistent_data()
	if not stage_to_load:
		return
	var new_stage = load(stage_to_load).instantiate() as Stage
	add_child(new_stage)
	current_stage = new_stage
	pass

func load_persistent_data():
	if not FileAccess.file_exists("user://persistent_data.json"):
		return
	var file = FileAccess.open("user://persistent_data.json", FileAccess.READ)
	persistent_data = JSON.parse_string(file.get_as_text())
	persistent_data_loaded.emit(persistent_data)
	
func save_persistent_data():
	var file = FileAccess.open("user://persistent_data.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(persistent_data)) 
