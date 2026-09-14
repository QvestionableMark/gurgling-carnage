extends CanvasLayer

@onready var game : Game = get_tree().get_first_node_in_group("game")

func _ready() -> void:
	game.persistent_data_loaded.connect(on_persistent_data_loaded)

func on_persistent_data_loaded(persistent_data):
	print(persistent_data)
	$button_container/continue_button.visible = persistent_data.checkpoint != -1


func _on_continue_button_pressed() -> void:
	self.visible = false
	game.continue_old_game()


func _on_new_game_button_pressed() -> void:
	self.visible = false
	game.start_new_game()


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.
