extends Attack

const TARGET_MIN_X: float = 0.4
const TARGET_RANDOM_DIVISOR: int = 5
const TARGET_Y: float = 0.5
const PARRY_SPEED_MULTIPLIER: float = 1.5
const HIT_END_LAG: float = 0.3
const UNPARRIED_DAMAGE_DIVISOR: int = 6

var speed: float = 400.0
var direction: Vector2

var is_finished: bool = false

func _ready() -> void:
	if not has_parry_indicator:
		$parry_indicator_sprite.queue_free()
	var target: Vector2 = Vector2((TARGET_MIN_X + randf() / TARGET_RANDOM_DIVISOR) * Game.GAME_VIEW_SIZE.x, Game.GAME_VIEW_SIZE.y * TARGET_Y)
	look_at(target)
	direction = position.direction_to(target)

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
	been_parried = true

func _on_hit_area_body_entered(body: Node2D) -> void:
	if is_finished:
		return

	var hit_something: bool = false
	if body is Player and not been_parried:
		body.take_damage(hit_damage)
		body.end_lag += HIT_END_LAG
		hit_something = true

	if body.is_in_group("solid"):
		hit_something = true

	if body.is_in_group("boss"):
		if not been_parried:
			hit_damage /= UNPARRIED_DAMAGE_DIVISOR
		body.get_parent().get_parent().take_damage(hit_damage)
		hit_something = true

	if hit_something:
		is_finished = true
		add_collision_exception_with(body)
		$RockSprite.play("hit")
		await $RockSprite.animation_finished
		queue_free()
