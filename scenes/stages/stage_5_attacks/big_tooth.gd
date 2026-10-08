extends Attack

const HIT_END_LAG: float = 0.5
const HIT_KNOCKBACK: int = 1000

var speed: float = 550.0
var direction: Vector2

var is_finished: bool = false

func _ready() -> void:
	var target: Vector2 = global_position + Vector2(1, 0)
	look_at(target)
	direction = position.direction_to(target)
	sync_to_physics = true
	await get_tree().physics_frame
	visible = true

func _physics_process(delta: float) -> void:
	if is_finished:
		return
	position += direction * speed * delta

func _on_hit_area_body_entered(body: Node2D) -> void:
	var hit_something: bool = false
	if body is Player:
		body.take_damage(hit_damage)
		body.end_lag += HIT_END_LAG
		body.external_velocity += position.direction_to(body.position) * HIT_KNOCKBACK
		hit_something = true

	if body.is_in_group("solid"):
		hit_something = true

	if hit_something:
		is_finished = true
		add_collision_exception_with(body)
		$BigToothSprite.play("hit")
		await $BigToothSprite.animation_finished
		queue_free()
