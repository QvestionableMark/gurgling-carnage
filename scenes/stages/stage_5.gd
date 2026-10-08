extends Stage

@onready var BIG_TOOTH : PackedScene = preload("res://scenes/stages/stage_5_attacks/big_tooth.tscn")
@onready var TENTACLE : PackedScene = preload("res://scenes/stages/stage_1_attacks/tentacles.tscn")

func _ready() -> void:
	super()
	if game.persistent_data.tutorial:
		$Scalar/BossBody.has_parry_indicator = game.persistent_data.tutorial
	else:
		$Scalar/BossBody/parry_indicator_sprite.queue_free()
	var fade = STAGE_FADE.instantiate() as StageFade
	fade.fade_into_black = false
	add_child(fade)
	await fade.fade_done
	is_active = true

func _on_attack_timer_timeout() -> void:
	if not is_active:
		return
	
	if  randf() < 0.66:
		var rng = randf()
		if rng < 0.5:
			var big_tooth = BIG_TOOTH.instantiate() as Attack
			big_tooth.global_position = $Scalar/ToothSpawner.global_position
			add_child(big_tooth)
		elif rng < 1.0:
			for i in 2:
				var tentacle = TENTACLE.instantiate() as Attack
				var random_spawner = $Scalar/TentacleSpawners.get_child(randi() % 4)
				if random_spawner.get_child_count() == 0:
					random_spawner.add_child(tentacle)

func take_damage(damage):
	boss_current_health -= damage
	game.hud_update.emit()
	$OnHitAudio.play()

	if boss_current_health <= 0:
		is_active = false
		var fade = STAGE_FADE.instantiate() as StageFade
		add_child(fade)
		await fade.fade_done
		game.load_stage.call_deferred(stage_number + 1)
