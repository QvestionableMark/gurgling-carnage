extends Stage

const BIG_TOOTH: PackedScene = preload("res://scenes/stages/stage_5_attacks/big_tooth.tscn")
const TENTACLE: PackedScene = preload("res://scenes/stages/stage_1_attacks/tentacles.tscn")

const ATTACK_CHANCE: float = 0.66
const BIG_TOOTH_CHANCE: float = 0.5
const TENTACLE_COUNT: int = 2
const TENTACLE_SPAWNER_COUNT: int = 4

func _ready() -> void:
	super()
	if game.persistent_data.tutorial:
		$ScalarNode/BossBody.has_parry_indicator = game.persistent_data.tutorial
	else:
		$ScalarNode/BossBody/parry_indicator_sprite.queue_free()
	var fade: StageFade = STAGE_FADE.instantiate() as StageFade
	fade.fade_into_black = false
	add_child(fade)
	await fade.fade_done
	is_active = true

func _on_attack_timer_timeout() -> void:
	if not is_active:
		return

	if randf() < ATTACK_CHANCE:
		var rng: float = randf()
		if rng < BIG_TOOTH_CHANCE:
			var big_tooth: Attack = BIG_TOOTH.instantiate() as Attack
			big_tooth.global_position = $ScalarNode/ToothSpawnerNode.global_position
			add_child(big_tooth)
		elif rng < 1.0:
			for i: int in TENTACLE_COUNT:
				var tentacle: Tentacles = TENTACLE.instantiate() as Tentacles
				var random_spawner: Node2D = $ScalarNode/TentacleSpawnersNode.get_child(randi() % TENTACLE_SPAWNER_COUNT)
				if random_spawner.get_child_count() == 0:
					random_spawner.add_child(tentacle)

func take_damage(damage: float) -> void:
	boss_current_health -= damage
	game.hud_update.emit()
	$OnHitAudio.play()

	if boss_current_health <= 0:
		is_active = false
		var fade: StageFade = STAGE_FADE.instantiate() as StageFade
		add_child(fade)
		await fade.fade_done
		game.load_stage.call_deferred(stage_number + 1)
