extends Stage

const STAGE_ENTRY_FADE_DURATION: float = 2.0
const STAGE_EXIT_FADE_DURATION: float = 0.5

const ROCK: PackedScene = preload("res://scenes/stages/stage_3_attacks/rock.tscn")

const NORMAL_ATTACK_INTERVAL_MULTIPLIER: int = 2
const END_TRANSITION_FRAME: int = 10
const FATAL_COLLISION_FRAME: int = 80
const FATAL_DAMAGE_MULTIPLIER: int = 999
const ROCK_SPAWN_MIN_X: float = 0.1
const ROCK_SPAWN_MAX_X: float = 0.9
const ROCK_SPAWN_Y: int = -1000
const COLLISION_KNOCKBACK_MULTIPLIER: float = 1.5

var top_mouth_start_position: Vector2
var bottom_mouth_start_position: Vector2

func _ready() -> void:
	super()
	if not game.persistent_data.hardmode:
		$AttackTimer.wait_time *= NORMAL_ATTACK_INTERVAL_MULTIPLIER
	var entry_fade: StageFade = STAGE_FADE.instantiate() as StageFade
	entry_fade.fade_duration = STAGE_ENTRY_FADE_DURATION
	entry_fade.fade_into_black = false
	add_child(entry_fade)
	await entry_fade.fade_done
	$BackgroundSprite.play("default")
	$MouthColliderAnimation.play("mouth_movement")
	is_active = true

func take_damage(damage: float) -> void:
	boss_current_health -= damage
	game.hud_update.emit()
	$OnHitAudio.play()

	if boss_current_health <= 0:
		$BackgroundSprite.play("end_transition")
		$MouthColliderAnimation.play("transition_position")
		is_active = false
		while $BackgroundSprite.frame < END_TRANSITION_FRAME:
			await $BackgroundSprite.frame_changed
		$FloorBody.queue_free()

func _process(_delta: float) -> void:
	if player.position.y > Game.GAME_VIEW_SIZE.y and not is_exiting:
		is_exiting = true
		var exit_fade: StageFade = STAGE_FADE.instantiate() as StageFade
		exit_fade.fade_duration = STAGE_EXIT_FADE_DURATION
		add_child(exit_fade)
		await exit_fade.fade_done
		game.load_stage.call_deferred(stage_number + 1)

func _on_attack_timer_timeout() -> void:
	if not is_active:
		return

	var rock: Attack = ROCK.instantiate()
	var spawn_x: float = randf_range(Game.GAME_VIEW_SIZE.x * ROCK_SPAWN_MIN_X, Game.GAME_VIEW_SIZE.x * ROCK_SPAWN_MAX_X)
	rock.has_parry_indicator = game.persistent_data.tutorial
	rock.global_position = Vector2(spawn_x, ROCK_SPAWN_Y)
	add_child(rock)

func _on_knockback_area_body_entered(body: Node2D) -> void:
	if body is Player and boss_current_health > 0:
		if $BackgroundSprite.frame > FATAL_COLLISION_FRAME:
			body.take_damage(COLLISION_DAMAGE * FATAL_DAMAGE_MULTIPLIER)
		body.take_damage(COLLISION_DAMAGE)
		body.end_lag += COLLISION_END_LAG
		body.input_velocity = Vector2.ZERO
		body.external_velocity += (Vector2(Game.GAME_VIEW_SIZE.x * 0.5, 0) - player.global_position) * COLLISION_KNOCKBACK_MULTIPLIER
