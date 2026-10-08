class_name Game
extends Node2D

signal persistent_data_loaded()
signal stage_loaded(stage_number: int)
signal hud_update()
signal player_died(timer: Timer)
signal game_paused(new_state: bool)

const MAX_HEALTH: int = 100
const HARDMODE_MULTIPLIER: int = 2
const MENU_STAGE: int = -1
const PERSISTENT_DATA_PATH: String = "user://persistent_data.json"
const GAME_VIEW_SIZE: Vector2 = Vector2(1920, 1080)

@export var stages: Array[String]

var persistent_data: Dictionary = {
	"checkpoint": MENU_STAGE,
	"health": MAX_HEALTH,
	"tutorial": true,
	"hardmode": false,
	"beat_normal": false,
	"beat_hard": false,
	"beat_hard_hitless": false,
	"volume": 0.5
}

var current_stage: Stage
var current_player: Player

var is_paused: bool

@onready var hud: GameHud = $hud

func _ready() -> void:
	load_persistent_data()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause") and current_stage:
		pause_game(not get_tree().paused)

func pause_game(new_state: bool) -> void:
	get_tree().paused = new_state
	game_paused.emit(new_state)

func start_new_game(with_tutorial: bool, with_hardmode: bool) -> void:
	pause_game(false)
	persistent_data.checkpoint = 0
	persistent_data.health = MAX_HEALTH
	persistent_data.hardmode = with_hardmode
	persistent_data.tutorial = with_tutorial
	save_persistent_data()

	continue_old_game()

func continue_old_game() -> void:
	if not persistent_data.hardmode:
		persistent_data.health = MAX_HEALTH
	load_stage(persistent_data.checkpoint)

func handle_death() -> void:
	if persistent_data.hardmode:
		persistent_data.checkpoint = MENU_STAGE
	get_tree().paused = true
	$DeathTimer.start()
	player_died.emit($DeathTimer)
	await $DeathTimer.timeout
	get_tree().paused = false
	persistent_data.health = MAX_HEALTH
	load_stage(MENU_STAGE)
	save_persistent_data()

func handle_win() -> void:
	persistent_data.beat_normal = true
	if persistent_data.hardmode:
		persistent_data.beat_hard = true
		if persistent_data.health == MAX_HEALTH:
			persistent_data.beat_hard_hitless = true

	load_stage(MENU_STAGE)
	save_persistent_data()

func create_slowmo(slowmo_strength: float, slowmo_time: float) -> void:
	Engine.time_scale = 1 - slowmo_strength
	hud.start_vignette(slowmo_strength, slowmo_time / slowmo_strength + slowmo_time)
	await get_tree().create_timer(slowmo_time, true, false, true).timeout
	Engine.time_scale = 1

func load_stage(stage_number_to_load: int) -> void:
	if stage_number_to_load == MENU_STAGE:
		pause_game(false)
	if current_stage:
		current_stage.queue_free()
	if stage_number_to_load == MENU_STAGE:
		stage_loaded.emit(stage_number_to_load)
		return
	var new_stage: Stage = load(stages[stage_number_to_load]).instantiate() as Stage
	add_child(new_stage)
	current_stage = new_stage
	stage_loaded.emit(stage_number_to_load)
	hud_update.emit()
	save_persistent_data()

func load_persistent_data() -> void:
	if not FileAccess.file_exists(PERSISTENT_DATA_PATH):
		persistent_data_loaded.emit()
		return
	var file: FileAccess = FileAccess.open(PERSISTENT_DATA_PATH, FileAccess.READ)
	var loaded_persistent_data: Dictionary = JSON.parse_string(file.get_as_text())
	loaded_persistent_data.merge(persistent_data)
	persistent_data = loaded_persistent_data
	persistent_data_loaded.emit()
	#print(persistent_data)

func save_persistent_data() -> void:
	var file: FileAccess = FileAccess.open(PERSISTENT_DATA_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(persistent_data))
