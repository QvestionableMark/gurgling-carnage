extends Attack

const TARGET_MIN_Y: float = -0.75
const TARGET_Y_RANGE: float = 1.5
const SPEED_RANDOM_DIVISOR: int = 2
const SPEED_MIN_MULTIPLIER: float = 0.3
const HIT_END_LAG: float = 0.7

var velocity: Vector2

func _init() -> void:
	speed = 1500.0

func _ready() -> void:
	var trajectory_roll: float = randf()
	var target_position: Vector2 = Vector2(0, (TARGET_MIN_Y + trajectory_roll * TARGET_Y_RANGE) * Game.GAME_VIEW_SIZE.y)
	look_at(target_position)
	velocity = position.direction_to(target_position) * speed * (trajectory_roll / SPEED_RANDOM_DIVISOR + SPEED_MIN_MULTIPLIER)
	visible = true

func _physics_process(delta: float) -> void:
	if not is_finished:
		velocity += get_gravity() * delta
		rotation = velocity.angle()
		var collision: KinematicCollision2D = move_and_collide(velocity * delta)
		if collision:
			rotation = (-collision.get_normal()).angle()
			on_hit(collision.get_collider())

func on_hit(body: Node2D) -> void:
	if is_finished:
		return

	var is_target_hit: bool = false
	if body is Player:
		body.take_damage(hit_damage)
		body.end_lag += HIT_END_LAG
		is_target_hit = true

	if body.is_in_group("solid"):
		is_target_hit = true

	if is_target_hit:
		is_finished = true
		$AcidCollision.set_deferred("disabled", true)
		add_collision_exception_with(body)
		$AcidSprite.play("hit")
		await $AcidSprite.animation_finished
		queue_free()
