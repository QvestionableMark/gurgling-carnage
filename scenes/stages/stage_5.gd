extends Stage

const STAGE_ENTRY_FADE_DURATION: float = 2.0
const STAGE_EXIT_FADE_DURATION: float = 2.0

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
	var entry_fade: StageFade = STAGE_FADE.instantiate() as StageFade
	entry_fade.fade_duration = STAGE_ENTRY_FADE_DURATION
	entry_fade.fade_into_black = false
	add_child(entry_fade)
	await entry_fade.fade_done
	is_active = true

func _on_attack_timer_timeout() -> void:
	if not is_active:
		return

	if randf() < ATTACK_CHANCE:
		var attack_roll: float = randf()
		if attack_roll < BIG_TOOTH_CHANCE:
			var big_tooth: Attack = BIG_TOOTH.instantiate() as Attack
			big_tooth.global_position = $ScalarNode/ToothSpawnerNode.global_position
			add_child(big_tooth)
		elif attack_roll < 1.0:
			for tentacle_index: int in TENTACLE_COUNT:
				var tentacle: Tentacles = TENTACLE.instantiate() as Tentacles
				var tentacle_spawner: Node2D = $ScalarNode/TentacleSpawnersNode.get_child(randi() % TENTACLE_SPAWNER_COUNT)
				if tentacle_spawner.get_child_count() == 0:
					tentacle_spawner.add_child(tentacle)

func take_damage(damage: float) -> void:
	boss_current_health -= damage
	game.hud_update.emit()
	$OnHitAudio.play()

	if boss_current_health <= 0:
		is_active = false
		var exit_fade: StageFade = STAGE_FADE.instantiate() as StageFade
		exit_fade.fade_duration = STAGE_EXIT_FADE_DURATION
		add_child(exit_fade)
		await exit_fade.fade_done
		game.load_stage.call_deferred(stage_number + 1)
