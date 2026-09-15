extends Node

@onready var game : Game = get_tree().get_first_node_in_group("game")

func _process(_delta: float) -> void:
		var current_stage_number
		if (game.current_stage):
			current_stage_number = game.current_stage.stage_number
		else:
			current_stage_number = -1
		
		if Input.is_action_just_pressed("debug_next_stage"):
			game.load_stage(clamp(current_stage_number + 1, -1, game.stages.size() - 1))
		if Input.is_action_just_pressed("debug_previous_stage"):
			game.load_stage(clamp(current_stage_number - 1, -1, game.stages.size() - 1))
