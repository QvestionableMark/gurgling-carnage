extends Attack

const SPEED = 1300

var velocity
var is_finished = false

func _ready() -> void:
	var target = Vector2(0,(-0.25 + randf() / 2) * 1080)
	look_at(target)
	velocity = position.direction_to(target) * SPEED
	visible = true

func _physics_process(delta: float) -> void:
	if not is_finished:
		velocity += get_gravity() * delta
		rotation = velocity.angle()
		var collision = move_and_collide(velocity * delta)
		if collision:
			rotation = (-collision.get_normal()).angle()
			on_hit(collision.get_collider())
			

func on_hit(body: Node2D) -> void:
	if is_finished:
		return
	
	var hit_something = false
	if body is Player:
		body.take_damage(hit_damage)
		body.end_lag += 0.7
		hit_something = true

	if body.is_in_group("solid"):
		hit_something = true
		
	if hit_something:
		is_finished = true
		add_collision_exception_with(body)
		$AnimatedSprite2D.play("hit")
		await $AnimatedSprite2D.animation_finished
		queue_free()
