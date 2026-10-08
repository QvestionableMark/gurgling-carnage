extends Attack

const TARGET_MIN_Y: float = 0.45
const TARGET_RANDOM_DIVISOR: int = 5
const HIT_END_LAG: float = 0.5
const HIT_KNOCKBACK: int = 1000

func _ready() -> void:
	if not has_parry_indicator:
		$parry_indicator_sprite.queue_free()
	var target_position: Vector2 = Vector2(0, (TARGET_MIN_Y + randf() / TARGET_RANDOM_DIVISOR) * Game.GAME_VIEW_SIZE.y)
	look_at(target_position)
	direction = position.direction_to(target_position)
	sync_to_physics = true
	await get_tree().physics_frame
	visible = true

func _physics_process(delta: float) -> void:
	if is_finished:
		return
	position += direction * speed * delta

func handle_parry(player: Player) -> void:
	if is_finished:
		return
	sync_to_physics = false
	direction = player.global_position.direction_to(global_position)
	look_at(global_position + direction)
	sync_to_physics = true
	has_been_parried = true

func _on_hit_area_body_entered(body: Node2D) -> void:
	var is_target_hit: bool = false
	if not has_been_parried and body is Player:
		body.take_damage(hit_damage)
		body.end_lag += HIT_END_LAG
		body.external_velocity += position.direction_to(body.position) * HIT_KNOCKBACK
		is_target_hit = true

	if has_been_parried and body.is_in_group("boss"):
		body.get_parent().take_damage(hit_damage)
		is_target_hit = true

	if body.is_in_group("solid"):
		is_target_hit = true

	if is_target_hit:
		is_finished = true
		$ToothCollision.set_deferred("disabled", true)
		$HitArea.set_deferred("monitoring", false)
		add_collision_exception_with(body)
		$ToothSprite.play("hit")
		await $ToothSprite.animation_finished
		queue_free()
