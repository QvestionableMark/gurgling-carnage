extends Attack

const TARGET_MIN_X: float = 0.4
const TARGET_RANDOM_DIVISOR: int = 5
const TARGET_Y: float = 0.5
const PARRY_SPEED_MULTIPLIER: float = 1.5
const HIT_END_LAG: float = 0.3
const UNPARRIED_DAMAGE_DIVISOR: int = 6

func _init() -> void:
	speed = 400.0

func _ready() -> void:
	if not has_parry_indicator:
		$parry_indicator_sprite.queue_free()
	var target_position: Vector2 = Vector2((TARGET_MIN_X + randf() / TARGET_RANDOM_DIVISOR) * Game.GAME_VIEW_SIZE.x, Game.GAME_VIEW_SIZE.y * TARGET_Y)
	look_at(target_position)
	direction = position.direction_to(target_position)

	rotation = direction.angle()

	sync_to_physics = true
	await get_tree().physics_frame
	visible = true

func _physics_process(delta: float) -> void:
	if not is_finished:
		position += direction * speed * delta

func handle_parry(player: Player) -> void:
	if is_finished:
		return
	sync_to_physics = false
	direction.x = (-global_position.direction_to(player.global_position)).x
	rotation = direction.angle()
	speed *= PARRY_SPEED_MULTIPLIER
	$RockSprite.speed_scale *= PARRY_SPEED_MULTIPLIER
	sync_to_physics = true
	has_been_parried = true

func _on_hit_area_body_entered(body: Node2D) -> void:
	if is_finished:
		return

	var is_target_hit: bool = false
	if body is Player and not has_been_parried:
		body.take_damage(hit_damage)
		body.end_lag += HIT_END_LAG
		is_target_hit = true

	if body.is_in_group("solid"):
		is_target_hit = true

	if body.is_in_group("boss"):
		if not has_been_parried:
			hit_damage /= UNPARRIED_DAMAGE_DIVISOR
		body.get_parent().get_parent().take_damage(hit_damage)
		is_target_hit = true

	if is_target_hit:
		is_finished = true
		add_collision_exception_with(body)
		$RockSprite.play("hit")
		await $RockSprite.animation_finished
		queue_free()
