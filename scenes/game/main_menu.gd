extends CanvasLayer

@onready var game : Game = get_tree().get_first_node_in_group("game")

func _ready() -> void:
	game.persistent_data_loaded.connect(_on_persistent_data_loaded)
	game.stage_loaded.connect(_on_stage_loaded)

func _on_persistent_data_loaded(persistent_data):
	initialization()
	

func _on_stage_loaded(stage_number):
	if stage_number == -1:
		visible = true
		initialization()
	else:
		visible = false

func initialization():
	$button_container/continue_button.visible = game.persistent_data.checkpoint != 0
	$button_container/new_game_button/tutorial.button_pressed = game.persistent_data.tutorial

func _on_continue_button_pressed() -> void:
	self.visible = false
	game.continue_old_game()


func _on_new_game_button_pressed() -> void:
	self.visible = false
	game.start_new_game($button_container/new_game_button/tutorial.button_pressed)
