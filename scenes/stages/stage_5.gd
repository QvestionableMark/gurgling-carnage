extends Stage

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

func take_damage(damage):
	boss_current_health -= damage
	game.hud_update.emit()
	$OnHitAudio.play()

	if boss_current_health <= 0:
		is_active = false
		var fade = STAGE_FADE.instantiate() as StageFade
		add_child(fade)
		await fade.fade_done
