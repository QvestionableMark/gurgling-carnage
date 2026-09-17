extends Stage

@onready var PIERCING : PackedScene = preload("res://scenes/stages/stage_2_attacks/piercing.tscn")

func _ready() -> void:
	super()
	player.gravity *= -0.2
	player.fast_fall_gravity *= 0.4
	var fade = STAGE_FADE.instantiate() as StageFade
	fade.fade_into_black = false
	add_child(fade)
	await fade.fade_done

func _on_attack_timer_timeout() -> void:
	if randf() < 1.0/2.0 and Engine.time_scale != 0:
		var piercing = PIERCING.instantiate() as AnimatableBody2D
		add_child(piercing)


func _on_survival_timer_timeout() -> void:
	boss_current_health -= 1
	game.hud_update.emit()
	
	if boss_current_health <= 0:
		var fade = STAGE_FADE.instantiate() as StageFade
		add_child(fade)
		await fade.fade_done
		game.load_stage(3)
