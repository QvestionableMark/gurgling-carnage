extends Stage

@onready var ROCK : PackedScene = preload ("res://scenes/stages/stage_3_attacks/rock.tscn")

const COLLISION_DAMAGE = 35

var top_mouth_start_position
var bottom_mouth_start_position

var is_fading = false

func _ready() -> void:
	super()
	if not game.persistent_data.hardmode:
		$AttackTimer.wait_time *= 2
	var fade = STAGE_FADE.instantiate() as StageFade
	fade.fade_into_black = false
	add_child(fade)
	await fade.fade_done
	$Background.play("default")
	$MouthColliderAnimation.play("mouth_movement")
	is_active = true
	
func take_damage(damage):
	boss_current_health -= damage
	game.hud_update.emit()
	$OnHitAudio.play()

	if boss_current_health <= 0:
		$Background.play("end_transition")
		$MouthColliderAnimation.play("transition_position")
		is_active = false
		while $Background.frame < 10:
			await $Background.frame_changed
		$FloorBody.queue_free()
		
		
	
func _process(_delta: float) -> void:
	if player.position.y > game.GAME_VIEW_SIZE.y and not is_fading:
			is_fading = true
			var fade = STAGE_FADE.instantiate() as StageFade
			fade.fade_time = 0.5
			add_child(fade)
			await fade.fade_done
			game.load_stage.call_deferred(stage_number + 1)

func _on_attack_timer_timeout() -> void:
	if not is_active:
		return
	
	var rock = ROCK.instantiate() 
	var random_x = randf_range(Game.GAME_VIEW_SIZE.x * 0.1, Game.GAME_VIEW_SIZE.x * 0.9) 
	rock.has_parry_indicator = game.persistent_data.tutorial
	rock.global_position = Vector2(random_x, -100) 
	add_child(rock)


func _on_knockback_area_body_entered(body: Node2D) -> void:
	if body is Player and boss_current_health > 0:
		if $Background.frame > 80:
			body.take_damage(COLLISION_DAMAGE*999)
		body.take_damage(COLLISION_DAMAGE)
		body.end_lag += 0.5
		body.input_velocity = Vector2.ZERO
		body.external_velocity += (Vector2(Game.GAME_VIEW_SIZE.x * 0.5, 0) - player.global_position) * 1.5
