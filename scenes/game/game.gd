class_name Game
extends Node2D
 
var persistent_data = {
	"checkpoint": -1,
	"health": 100,
	"tutorial": true,
	"hardmode": false
}
signal persistent_data_loaded()
signal stage_loaded(stage_number)
signal hud_update()
signal player_died(timer)
signal game_paused(newState)

@export var stages : Array[String]
var current_stage : Stage
var current_player : Player
var is_paused : bool

func _ready() -> void:
	load_persistent_data()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and current_stage:
		pause_game(not get_tree().paused)

func pause_game(newState):
	get_tree().paused = newState
	game_paused.emit(newState)

func start_new_game(with_tutorial, with_hardmode):
	pause_game(false)
	persistent_data.checkpoint = 0
	persistent_data.health = 100
	persistent_data.hardmode = with_hardmode
	persistent_data.tutorial = with_tutorial
	save_persistent_data()
	
	continue_old_game()
	

func continue_old_game():
	if not persistent_data.hardmode:
		persistent_data.health = 100
	load_stage(persistent_data.checkpoint)

func handle_death():
	if persistent_data.hardmode:
		persistent_data.checkpoint = -1
	get_tree().paused = true
	$DeathTimer.start()
	player_died.emit($DeathTimer)
	
	await $DeathTimer.timeout 
	get_tree().paused = false
	persistent_data.health = 100
	load_stage(-1)
	save_persistent_data()
	
func handle_win():
	load_stage(-1)
	save_persistent_data()

func load_stage(stage_number_to_load):
	if stage_number_to_load == -1:
		pause_game(false)
	if current_stage:
		current_stage.queue_free()
	if stage_number_to_load == -1:
		stage_loaded.emit(stage_number_to_load)
		return
	var new_stage = load(stages[stage_number_to_load]).instantiate() as Stage
	add_child(new_stage)
	current_stage = new_stage
	stage_loaded.emit(stage_number_to_load)
	hud_update.emit()
	save_persistent_data()

func load_persistent_data():
	if not FileAccess.file_exists("user://persistent_data.json"):
		return
	var file = FileAccess.open("user://persistent_data.json", FileAccess.READ)
	var loaded_persistent_data : Dictionary = JSON.parse_string(file.get_as_text())
	loaded_persistent_data.merge(persistent_data)
	persistent_data = loaded_persistent_data
	persistent_data_loaded.emit()
	#print(persistent_data)
	
func save_persistent_data():
	var file = FileAccess.open("user://persistent_data.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(persistent_data)) 
