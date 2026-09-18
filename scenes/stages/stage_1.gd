extends Stage

@onready var TOOTH : PackedScene = preload("res://scenes/stages/stage_1_attacks/tooth.tscn")
@onready var ACID : PackedScene = preload("res://scenes/stages/stage_1_attacks/acid.tscn")
@onready var TENTACLE : PackedScene = preload("res://scenes/stages/stage_1_attacks/tentacles.tscn")

const COLLISION_DAMAGE = 35

var is_spitting = false
var is_stabbing = false

func  _ready() -> void:
	super()
	await $Background.animation_finished
	$Background.play("default")
	is_active = true

func take_damage(damage):
	boss_current_health -= damage
	game.hud_update.emit()
	
	if boss_current_health <= 0:
		is_active = false
		var fade = STAGE_FADE.instantiate() as StageFade
		fade.fade_time = 5
		add_child(fade)
		await fade.fade_done
		game.load_stage.call_deferred(stage_number + 1)

func _on_attack_timer_timeout() -> void:
	if not is_active:
		return
	
	if  randf() < 1.0/3.0:
		var rng = randf()
		if not is_spitting and rng < 0.3:
			is_spitting = true
			$BossBody/AnimatedSprite2D.play("spit")
			while $BossBody/AnimatedSprite2D.frame != 5:
				await $BossBody/AnimatedSprite2D.frame_changed
			var tooth = TOOTH.instantiate() as Attack
			tooth.global_position = $BossBody/MouthPosition.global_position
			tooth.has_parry_indicator = game.persistent_data.tutorial
			add_child(tooth)
			await $BossBody/AnimatedSprite2D.animation_finished
			$BossBody/AnimatedSprite2D.play("default")
			is_spitting = false
		elif not is_spitting and rng < 0.7:
			is_spitting = true
			$BossBody/AnimatedSprite2D.play("spit")
			while $BossBody/AnimatedSprite2D.frame != 5:
				await $BossBody/AnimatedSprite2D.frame_changed
			var acid = ACID.instantiate() as Attack
			acid.global_position = $BossBody/MouthPosition.global_position
			add_child(acid)
			await $BossBody/AnimatedSprite2D.animation_finished
			$BossBody/AnimatedSprite2D.play("default")
			is_spitting = false
		elif not is_stabbing and rng < 1.0:
			is_stabbing = true
			var tentacle = TENTACLE.instantiate() as Attack
			add_child(tentacle)
			await tentacle.finished
			is_stabbing = false

func _on_knockback_area_body_entered(body: Node2D) -> void:
	if body is Player and boss_current_health > 0:
		body.take_damage(COLLISION_DAMAGE)
		body.end_lag += 0.5
		body.external_velocity += Vector2(-1,-1).normalized() * 1500
