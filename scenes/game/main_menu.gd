extends CanvasLayer

@onready var game: Game = get_tree().get_first_node_in_group("game")

func _ready() -> void:
	game.persistent_data_loaded.connect(_on_persistent_data_loaded)
	game.stage_loaded.connect(_on_stage_loaded)
	game.game_paused.connect(_on_game_paused)

func _on_persistent_data_loaded() -> void:
	update_menu()

func _on_stage_loaded(stage_number: int) -> void:
	$BackgroundSprite.visible = true
	update_menu()
	if stage_number == Game.MENU_STAGE:
		visible = true
		update_menu()
	else:
		visible = false

func update_menu() -> void:
	$ButtonContainer/ContinueButton.visible = game.persistent_data.checkpoint > Game.MENU_STAGE
	$ButtonContainer/NewGameButton/NewGameOptionsContainer/TutorialToggleButton.button_pressed = game.persistent_data.tutorial
	$ButtonContainer/NewGameButton/NewGameOptionsContainer/HardmodeToggleButton.button_pressed = game.persistent_data.hardmode
	$TrophyContainer/BeatNormalTrophyTexture.visible = game.persistent_data.beat_normal
	$TrophyContainer/BeatHardTrophyTexture.visible = game.persistent_data.beat_hard
	$TrophyContainer/BeatHardHitlessTrophyTexture.visible = game.persistent_data.beat_hard_hitless
	$VolumeSlider.value = game.persistent_data.volume

func _on_game_paused(is_paused: bool) -> void:
	$BackgroundSprite.visible = not is_paused
	visible = is_paused

func _on_continue_button_pressed() -> void:
	if get_tree().paused:
		game.pause_game(false)
	else:
		self.visible = false
		game.continue_old_game()

func _on_new_game_button_pressed() -> void:
	self.visible = false
	game.start_new_game($ButtonContainer/NewGameButton/NewGameOptionsContainer/TutorialToggleButton.button_pressed, $ButtonContainer/NewGameButton/NewGameOptionsContainer/HardmodeToggleButton.button_pressed)

func _on_volume_slider_value_changed(value: float) -> void:
	var master_bus_index: int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_linear(master_bus_index, value)
	game.persistent_data.volume = value
	game.save_persistent_data()
