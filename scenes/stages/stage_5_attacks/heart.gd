extends Attack

@export var platform_body : StaticBody2D
var heart_beat_frames = [1,7,9,10,12,13,15,16]
var heart_just_beat = false

func handle_parry(player : Player):
	if been_parried:
		return
	player.external_velocity += global_position.direction_to(player.global_position) * 1500
	been_parried = true
	platform_body.collision_layer = 0
	get_parent().get_parent().take_damage(hit_damage)
	await get_tree().create_timer(2.0).timeout
	been_parried = false
	platform_body.collision_layer = 1
	
	

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(hit_damage)
		body.end_lag += 0.5
		body.external_velocity += global_position.direction_to(body.global_position) * 1000


func _on_boss_frame_changed() -> void:
	heart_just_beat = $Boss.frame in heart_beat_frames
	
	if heart_just_beat and not been_parried:
		$HeartCollision.add_to_group("parryable")
	else:
		$HeartCollision.remove_from_group("parryable")
	if has_parry_indicator:
		$parry_indicator_sprite.visible = heart_just_beat and not been_parried
