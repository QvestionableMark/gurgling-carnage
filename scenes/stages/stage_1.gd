extends Stage

const TOOTH: PackedScene = preload("res://scenes/stages/stage_1_attacks/tooth.tscn")
const ACID: PackedScene = preload("res://scenes/stages/stage_1_attacks/acid.tscn")
const TENTACLE: PackedScene = preload("res://scenes/stages/stage_1_attacks/tentacles.tscn")
const LASER: PackedScene = preload("res://scenes/stages/stage_1_attacks/laser_buzz.tscn")

const END_TRANSITION_FRAME: int = 18
const SPIT_RELEASE_FRAME: int = 5
const STAGE_EXIT_FADE_TIME: float = 0.5
const ATTACK_CHANCE: float = 0.66
const SPIT_CHANCE: float = 0.6
const TOOTH_CHANCE: float = 0.3
const TENTACLE_CHANCE: float = 0.7
const COLLISION_END_LAG: float = 0.5
const COLLISION_KNOCKBACK: int = 1500
const COLLISION_DAMAGE: int = 35

var is_spitting: bool = false
var is_stabbing: bool = false
var is_lasering: bool = false

func _ready() -> void:
	super()
	await $BackgroundSprite.animation_finished
	$BackgroundSprite.play("default")
	is_active = true

func take_damage(damage: float) -> void:
	boss_current_health -= damage
	game.hud_update.emit()
	$OnHitAudio.play()

	if boss_current_health <= 0:
		$BackgroundSprite.play("end_transition")
		is_active = false
		var boss_collider: CollisionShape2D = $BossBody/BossCollision
		boss_collider.reparent.call_deferred($FloorBody)
		$BossBody.queue_free()
		while $BackgroundSprite.frame < END_TRANSITION_FRAME:
			await $BackgroundSprite.frame_changed
		boss_collider.queue_free()

func _process(_delta: float) -> void:
	if player.position.y > Game.GAME_VIEW_SIZE.y:
		var fade: StageFade = STAGE_FADE.instantiate() as StageFade
		fade.fade_time = STAGE_EXIT_FADE_TIME
		add_child(fade)
		await fade.fade_done
		game.load_stage.call_deferred(stage_number + 1)

func _on_attack_timer_timeout() -> void:
	if not is_active:
		return

	if randf() < ATTACK_CHANCE:
		var rng: float = randf()
		if not is_spitting and rng < SPIT_CHANCE:
			is_spitting = true
			$BossBody/BossSprite.play("spit")
			$SpitAudio.play()
			while $BossBody/BossSprite.frame != SPIT_RELEASE_FRAME:
				await $BossBody/BossSprite.frame_changed
			if rng < TOOTH_CHANCE:
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
		elif not is_stabbing and rng < TENTACLE_CHANCE:
			is_stabbing = true
			var tentacle: Tentacles = TENTACLE.instantiate() as Tentacles
			$TentacleSpawnerNode.add_child(tentacle)
			await tentacle.finished
			is_stabbing = false
		elif not is_lasering:
			is_lasering = true
			var laser: LaserBuzz = LASER.instantiate() as LaserBuzz
			add_child(laser)
			$BuzzAudio.play()
			await laser.finished
			is_lasering = false

func _on_knockback_area_body_entered(body: Node2D) -> void:
	if body is Player and boss_current_health > 0:
		body.take_damage(COLLISION_DAMAGE)
		body.end_lag += COLLISION_END_LAG
		body.external_velocity += Vector2(-1, -1).normalized() * COLLISION_KNOCKBACK
