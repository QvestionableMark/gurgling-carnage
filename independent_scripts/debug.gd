extends Node

@onready var game: Game = get_tree().get_first_node_in_group("game")

func _process(_delta: float) -> void:
	var current_stage_number: int
	if (game.current_stage):
		current_stage_number = game.current_stage.stage_number
	else:
		current_stage_number = Game.MENU_STAGE

	if Input.is_action_just_pressed("debug_next_stage"):
		game.load_stage(clampi(current_stage_number + 1, Game.MENU_STAGE, game.stages.size() - 1))
	if Input.is_action_just_pressed("debug_previous_stage"):
		game.load_stage(clampi(current_stage_number - 1, Game.MENU_STAGE, game.stages.size() - 1))
	if Input.is_action_just_pressed("debug_clear_wins"):
		game.persistent_data.beat_normal = false
		game.persistent_data.beat_hard = false
		game.persistent_data.beat_hard_hitless = false
		game.load_stage(Game.MENU_STAGE)
		game.save_persistent_data()
