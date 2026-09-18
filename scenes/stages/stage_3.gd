extends Stage

@onready var ROCK : PackedScene = preload ("res://scenes/stages/stage_3_attacks/rock.tscn")

const COLLISION_DAMAGE = 35

func _ready() -> void:
	super()
	var fade = STAGE_FADE.instantiate() as StageFade
	fade.fade_into_black = false
	add_child(fade)
	await fade.fade_done
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
	
	if randf() < .33:
		
		var rock = ROCK.instantiate() 
		
		var random_x = randf_range(200, 1720) 
		
		
		rock.global_position = Vector2(random_x, -100) 
		
		add_child(rock)


func _on_knockback_area_body_entered(body: Node2D) -> void:
	if body is Player and boss_current_health > 0:
		body.take_damage(COLLISION_DAMAGE)
		body.end_lag += 0.5
		body.external_velocity += player.position.direction_to(Vector2(1920/2,1080/4)) * 500
