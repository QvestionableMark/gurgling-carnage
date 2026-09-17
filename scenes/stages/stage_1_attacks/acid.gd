extends Attack

const SPEED = 1000

var velocity
var is_finished = false

func _ready() -> void:
	var target = Vector2(0,(-0.75 + randf()) * 1080)
	look_at(target)
	velocity = position.direction_to(target) * SPEED
	visible = true

func _physics_process(delta: float) -> void:
	if not is_finished:
		velocity += get_gravity() * delta
		position += velocity * delta
		rotation = velocity.angle()

func _on_hit_area_body_entered(body: Node2D) -> void:
	if is_finished:
		return
	
	var hit_something = false
	if body is Player:
		body.take_damage(hit_damage)
		body.end_lag += 0.5
		hit_something = true

	if body.is_in_group("solid"):
		hit_something = true
		
	if hit_something:
		rotation = round((rotation - PI / 8) / (PI / 2)) * (PI / 2)
		is_finished = true
		add_collision_exception_with(body)
		$AnimatedSprite2D.play("hit")
		await $AnimatedSprite2D.animation_finished
		queue_free()
