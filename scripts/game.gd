class_name Game
extends Node2D

var persistent_data = {
	"checkpoint": 0,
	"timer": 0
}
signal persistent_data_loaded(new_data)

@export var stages : Array[String]
var current_stage : Stage
var is_paused : bool

func _ready() -> void:
	load_persistent_data()

func start_new_game():
	persistent_data.checkpoint = 0
	save_persistent_data()
	
	continue_old_game()
	

func continue_old_game():
	load_stage(stages[persistent_data.checkpoint])
	load_player()
	


func load_stage(stage_to_load):
	if current_stage:
		current_stage.queue_free()
	persistent_data.checkpoint = stages.find(stage_to_load)
	save_persistent_data()
	if not stage_to_load:
		return
	var new_stage = load(stage_to_load).instantiate() as Stage
	add_child(new_stage)
	current_stage = new_stage
	pass

func load_player():
	var player = load("res://scenes/in_game/player.tscn").instantiate() as CharacterBody2D
	add_child(player)
	player.position = current_stage.player_start_position

func load_persistent_data():
	if not FileAccess.file_exists("user://persistent_data.json"):
		return
	var file = FileAccess.open("user://persistent_data.json", FileAccess.READ)
	persistent_data = JSON.parse_string(file.get_as_text())
	persistent_data_loaded.emit(persistent_data)
	
func save_persistent_data():
	var file = FileAccess.open("user://persistent_data.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(persistent_data)) 
