extends CanvasLayer

@onready var game : Game = get_tree().get_first_node_in_group("game")

func _ready() -> void:
	game.stage_loaded.connect(_on_stage_loaded)
	game.hud_update.connect(_on_hud_update)
	game.player_died.connect(_on_player_died)

func _on_stage_loaded(stage_number):
	if stage_number == -1 or stage_number == game.stages.size() - 1:
		visible = false
	else:
		visible = true
	if stage_number == 0:
		$KeybindMenu/ToggleMenu.button_pressed = game.persistent_data.tutorial
		$BossBarContainer.visible = false
	else:
		$BossBarContainer.visible = true

func _on_toggle_menu_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$KeybindMenu.position += Vector2(400,0) #400 is "Keybinds" size
	else:
		$KeybindMenu.position -= Vector2(400,0)

func _on_hud_update():
	$HealthBarContainer/HealthBar.value = game.persistent_data.health
	$BossBarContainer/BossHealthBar.value = float(game.current_stage.boss_current_health) / game.current_stage.boss_health

func _on_player_died(timer):
	$DeathLabel.visible = true
	await timer.timeout
	$DeathLabel.visible = false
