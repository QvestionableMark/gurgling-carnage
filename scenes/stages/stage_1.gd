extends Stage

const TOOTH: PackedScene = preload("res://scenes/stages/stage_1_attacks/tooth.tscn")
const ACID: PackedScene = preload("res://scenes/stages/stage_1_attacks/acid.tscn")
const TENTACLE: PackedScene = preload("res://scenes/stages/stage_1_attacks/tentacles.tscn")
const LASER: PackedScene = preload("res://scenes/stages/stage_1_attacks/laser_buzz.tscn")

const END_TRANSITION_FRAME: int = 18
const SPIT_RELEASE_FRAME: int = 5
const STAGE_EXIT_FADE_DURATION: float = 0.5
const ATTACK_CHANCE: float = 0.66
const SPIT_CHANCE: float = 0.6
const TOOTH_CHANCE: float = 0.3
const TENTACLE_CHANCE: float = 0.7
const COLLISION_KNOCKBACK: int = 1500

var is_spitting: bool = false
var is_stabbing: bool = false
var is_firing_laser: bool = false

func _ready() -> void:
	super()
	await $BackgroundSprite.animation_finished
	$BackgroundSprite.play("default")
	is_active = true

func take_damage(damage: float) -> void:
	if boss_current_health <= 0.0:
		return

	boss_current_health -= damage
	$BossBody/BossSprite.self_modulate = Color.RED
	game.hud_update.emit()
	$OnHitAudio.play()

	if boss_current_health <= 0.0:
		$BackgroundSprite.play("end_transition")
		is_active = false
		var boss_collision: CollisionShape2D = $BossBody/BossCollision
		boss_collision.reparent.call_deferred($FloorBody)
		$BossBody.queue_free()
		while $BackgroundSprite.frame < END_TRANSITION_FRAME:
			await $BackgroundSprite.frame_changed
		boss_collision.queue_free()
		$TentacleSpawnerNode.queue_free()

func _process(delta: float) -> void:
	if has_node("BossBody/BossSprite"):
		$BossBody/BossSprite.self_modulate = $BossBody/BossSprite.self_modulate.lerp(Color.WHITE, clampf(delta, 0.0, 1.0))
	if player.position.y > Game.GAME_VIEW_SIZE.y:
		var exit_fade: StageFade = STAGE_FADE.instantiate() as StageFade
		exit_fade.fade_duration = STAGE_EXIT_FADE_DURATION
		add_child(exit_fade)
		await exit_fade.fade_done
		game.load_stage.call_deferred(stage_number + 1)

func _on_attack_timer_timeout() -> void:
	if not is_active:
		return

	if randf() < ATTACK_CHANCE:
		var attack_roll: float = randf()
		if not is_spitting and attack_roll < SPIT_CHANCE:
			is_spitting = true
			$BossBody/BossSprite.play("spit")
			$SpitAudio.play()
			while $BossBody/BossSprite.frame != SPIT_RELEASE_FRAME:
				await $BossBody/BossSprite.frame_changed
			if attack_roll < TOOTH_CHANCE:
				var tooth: Attack = TOOTH.instantiate() as Attack
				tooth.global_position = $BossBody/MouthPositionNode.global_position
				tooth.has_parry_indicator = game.persistent_data.tutorial
				add_child(tooth)
			else:
				var acid: Attack = ACID.instantiate() as Attack
				acid.global_position = $BossBody/MouthPositionNode.global_position
				add_child(acid)
			await $BossBody/BossSprite.animation_finished
			$BossBody/BossSprite.play("default")
			is_spitting = false
		elif not is_stabbing and attack_roll < TENTACLE_CHANCE:
			is_stabbing = true
			var tentacle: Tentacles = TENTACLE.instantiate() as Tentacles
			$TentacleSpawnerNode.add_child(tentacle)
			await tentacle.finished
			is_stabbing = false
		elif not is_firing_laser:
			is_firing_laser = true
			var laser: LaserBuzz = LASER.instantiate() as LaserBuzz
			add_child(laser)
			$BuzzAudio.play()
			await laser.finished
			is_firing_laser = false

func _on_knockback_area_body_entered(body: Node2D) -> void:
	if body is Player and boss_current_health > 0:
		body.take_damage(COLLISION_DAMAGE)
		body.end_lag += COLLISION_END_LAG
		body.external_velocity += Vector2(-1, -1).normalized() * COLLISION_KNOCKBACK
