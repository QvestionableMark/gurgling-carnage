extends CanvasLayer

@onready var game : Game = get_tree().get_first_node_in_group("game")
var vignette_tween : Tween

func _ready() -> void:
	game.stage_loaded.connect(_on_stage_loaded)
	game.hud_update.connect(_on_hud_update)
	game.player_died.connect(_on_player_died)

func start_vignette(strength: float, duration: float):
	if vignette_tween:
		vignette_tween.kill()

	var gradient = $VignetteTexture.texture.gradient

	vignette_tween = create_tween()
	vignette_tween.set_ignore_time_scale(true)
	
	vignette_tween.tween_method(
		func(value): gradient.set_color(1, Color(0, 0, 0, value)),
		gradient.get_color(1).a,
		strength,
		duration / 2.0
	)
	vignette_tween.tween_method(
		func(value): gradient.set_color(1, Color(0, 0, 0, value)),
		strength,
		0.0,
		duration / 2.0
	)

func _on_stage_loaded(stage_number):
	if stage_number == -1 or stage_number == game.stages.size() - 1:
		visible = false
	else:
		visible = true
	if stage_number == 0:
		$KeybindMenu/ToggleMenu.button_pressed = game.persistent_data.tutorial
	
	if (game.current_stage):
		$BossBarContainer.visible = game.current_stage.use_boss_health_bar
	else:
		$BossBarContainer.visible = false

func _on_toggle_menu_toggled(toggled_on: bool) -> void:
	print(toggled_on)
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
