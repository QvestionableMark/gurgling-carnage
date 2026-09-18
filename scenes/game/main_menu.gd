extends CanvasLayer

@onready var game : Game = get_tree().get_first_node_in_group("game")

func _ready() -> void:
	game.persistent_data_loaded.connect(_on_persistent_data_loaded)
	game.stage_loaded.connect(_on_stage_loaded)
	game.game_paused.connect(_on_game_paused)

func _on_persistent_data_loaded():
	initialization()

func _on_stage_loaded(stage_number):
	$BackgroundSprite.visible = true
	initialization()
	if stage_number == -1:
		visible = true
		initialization()
	else:
		visible = false

func initialization():
	$ButtonContainer/ContinueButton.visible = game.persistent_data.checkpoint > -1
	$ButtonContainer/NewGameButton/HBoxContainer/TutorialToggle.button_pressed = game.persistent_data.tutorial
	$ButtonContainer/NewGameButton/HBoxContainer/HardmodeToggle.button_pressed = game.persistent_data.hardmode
	$TrophyContainer/BeatNormalTrophyTexture.visible = game.persistent_data.beat_normal
	$TrophyContainer/BeatHardTrophyTexture.visible = game.persistent_data.beat_hard
	$TrophyContainer/BeatHardHitlessTrophyTexture.visible = game.persistent_data.beat_hard_hitless
	

func _on_game_paused(newState) -> void:
	$BackgroundSprite.visible = not newState
	visible = newState

func _on_continue_button_pressed() -> void:
	if get_tree().paused:
		game.pause_game(false)
	else:
		self.visible = false
		game.continue_old_game()


func _on_new_game_button_pressed() -> void:
	self.visible = false
	game.start_new_game($ButtonContainer/NewGameButton/HBoxContainer/TutorialToggle.button_pressed, $ButtonContainer/NewGameButton/HBoxContainer/HardmodeToggle.button_pressed)
