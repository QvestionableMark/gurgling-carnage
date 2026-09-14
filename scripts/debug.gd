extends Node

@onready var game : Game = get_parent()

func _process(delta: float) -> void:
		var current_stage_number
		if (game.current_stage):
			current_stage_number = game.current_stage.stage_number
		else:
			current_stage_number = -1
		
		if Input.is_action_just_pressed("debug_next_stage"):
			game.load_stage(game.stages[clamp(current_stage_number + 1, 0, game.stages.size() - 1)])
			print("Next stage", current_stage_number)
		if Input.is_action_just_pressed("debug_previous_stage"):
			game.load_stage(game.stages[clamp(current_stage_number - 1, 0, game.stages.size() - 1)])
			print("Prev stage", current_stage_number)
			
		
