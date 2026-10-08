extends Attack

const TARGET_MIN_Y: float = 0.45
const TARGET_RANDOM_DIVISOR: int = 5
const HIT_END_LAG: float = 0.5
const HIT_KNOCKBACK: int = 1000

var speed: float = 550.0
var direction: Vector2

var is_finished: bool = false

func _ready() -> void:
	if not has_parry_indicator:
		$parry_indicator_sprite.queue_free()
	var target: Vector2 = Vector2(0, (TARGET_MIN_Y + randf() / TARGET_RANDOM_DIVISOR) * Game.GAME_VIEW_SIZE.y)
	look_at(target)
	direction = position.direction_to(target)
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
	been_parried = true

func _on_hit_area_body_entered(body: Node2D) -> void:
	var hit_something: bool = false
	if not been_parried and body is Player:
		body.take_damage(hit_damage)
		body.end_lag += HIT_END_LAG
		body.external_velocity += position.direction_to(body.position) * HIT_KNOCKBACK
		hit_something = true

	if been_parried and body.is_in_group("boss"):
		body.get_parent().take_damage(hit_damage)
		hit_something = true

	if body.is_in_group("solid"):
		hit_something = true

	if hit_something:
		is_finished = true
		add_collision_exception_with(body)
		$ToothSprite.play("hit")
		await $ToothSprite.animation_finished
		queue_free()
