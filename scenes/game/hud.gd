class_name GameHud
extends CanvasLayer

const KEYBIND_MENU_WIDTH: int = 400

var vignette_tween: Tween

@onready var game: Game = get_tree().get_first_node_in_group("game")

func _ready() -> void:
	game.stage_loaded.connect(_on_stage_loaded)
	game.hud_update.connect(_on_hud_update)
	game.player_died.connect(_on_player_died)

func start_vignette(strength: float, duration: float) -> void:
	if vignette_tween:
		vignette_tween.kill()

	var gradient: Gradient = $VignetteTexture.texture.gradient

	vignette_tween = create_tween()
	vignette_tween.set_ignore_time_scale(true)

	vignette_tween.tween_method(
		func(value: float) -> void: gradient.set_color(1, Color(0, 0, 0, value)),
		gradient.get_color(1).a,
		strength,
		duration / 2.0
	)
	vignette_tween.tween_method(
		func(value: float) -> void: gradient.set_color(1, Color(0, 0, 0, value)),
		strength,
		0.0,
		duration / 2.0
	)

func _on_stage_loaded(stage_number: int) -> void:
	if stage_number == Game.MENU_STAGE or stage_number == game.stages.size() - 1:
		visible = false
	else:
		visible = true
	if stage_number == 0:
		$KeybindMenuControl/ToggleMenuButton.button_pressed = game.persistent_data.tutorial

	if (game.current_stage):
		$BossBarContainer.visible = game.current_stage.use_boss_health_bar
	else:
		$BossBarContainer.visible = false

func _on_toggle_menu_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$KeybindMenuControl.position += Vector2(KEYBIND_MENU_WIDTH, 0)
	else:
		$KeybindMenuControl.position -= Vector2(KEYBIND_MENU_WIDTH, 0)

func _on_hud_update() -> void:
	$HealthBarContainer/HealthBar.value = game.persistent_data.health
	$BossBarContainer/BossHealthBar.value = float(game.current_stage.boss_current_health) / game.current_stage.boss_health

func _on_player_died(timer: Timer) -> void:
	$DeathLabel.visible = true
	await timer.timeout
	$DeathLabel.visible = false
