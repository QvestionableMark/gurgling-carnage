extends CanvasLayer

@onready var game : Game = get_tree().get_first_node_in_group("game")

func _ready() -> void:
	game.persistent_data_loaded.connect(on_persistent_data_loaded)

func on_persistent_data_loaded(persistent_data):
	print(persistent_data)
	$button_container/continue_button.visible = persistent_data.checkpoint != -1
