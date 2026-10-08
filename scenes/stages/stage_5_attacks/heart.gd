extends Attack

const PARRY_KNOCKBACK: int = 1500
const PARRY_RECOVERY_TIME: float = 2.0
const HIT_END_LAG: float = 0.5
const HIT_KNOCKBACK: int = 1000

@export var platform_body: StaticBody2D
@export var platform_sprite: Sprite2D

var heartbeat_frames: Array[int] = [1, 7, 9, 10, 12, 13, 15, 16]
var is_heartbeat_frame: bool = false

func _process(delta: float) -> void:
	$BossSprite.self_modulate = $BossSprite.self_modulate.lerp(Color.WHITE, clampf(delta, 0.0, 1.0))

func handle_parry(player: Player) -> void:
	if has_been_parried:
		return
	player.external_velocity += global_position.direction_to(player.global_position) * PARRY_KNOCKBACK
	has_been_parried = true
	platform_body.collision_layer = 0
	platform_sprite.self_modulate = Color.DIM_GRAY
	$BossSprite.self_modulate = Color.RED
	get_parent().get_parent().take_damage(hit_damage)
	await get_tree().create_timer(PARRY_RECOVERY_TIME).timeout
	has_been_parried = false
	platform_body.collision_layer = 1
	platform_sprite.self_modulate = Color.WHITE

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(hit_damage)
		body.end_lag += HIT_END_LAG
		body.external_velocity += global_position.direction_to(body.global_position) * HIT_KNOCKBACK

func _on_boss_sprite_frame_changed() -> void:
	is_heartbeat_frame = $BossSprite.frame in heartbeat_frames

	if is_heartbeat_frame and not has_been_parried:
		is_parryable = true
	else:
		is_parryable = false
	if has_parry_indicator:
		$parry_indicator_sprite.visible = is_heartbeat_frame and not has_been_parried
