extends Stage

const PIERCING: PackedScene = preload("res://scenes/stages/stage_2_attacks/piercing.tscn")

const GRAVITY_MULTIPLIER: float = -0.2
const FAST_FALL_GRAVITY_MULTIPLIER: float = 0.4
const ATTACK_CHANCE: float = 1.0 / 2.0

func _ready() -> void:
	super()
	player.gravity *= GRAVITY_MULTIPLIER
	player.fast_fall_gravity *= FAST_FALL_GRAVITY_MULTIPLIER
	var fade: StageFade = STAGE_FADE.instantiate() as StageFade
	fade.fade_into_black = false
	add_child(fade)
	await fade.fade_done
	is_active = true

func _on_attack_timer_timeout() -> void:
	if not is_active:
		return

	if randf() < ATTACK_CHANCE and Engine.time_scale != 0:
		var piercing: Attack = PIERCING.instantiate() as Attack
		add_child(piercing)

func _on_survival_timer_timeout() -> void:
	if not is_active:
		return
	boss_current_health -= 1
	game.hud_update.emit()

	if boss_current_health <= 0:
		is_active = false
		var fade: StageFade = STAGE_FADE.instantiate() as StageFade
		add_child(fade)
		await fade.fade_done
		game.load_stage(3)
