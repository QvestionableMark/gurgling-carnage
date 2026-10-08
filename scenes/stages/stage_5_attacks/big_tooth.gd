extends Attack

var speed = 550
var direction
var is_finished = false

func _ready() -> void:
	var target = global_position + Vector2(1,0)
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
	var hit_something = false
	if body is Player:
		body.take_damage(hit_damage)
		body.end_lag += 0.5
		body.external_velocity += position.direction_to(body.position) * 1000
		hit_something = true
		
	if body.is_in_group("solid"):
		hit_something = true
		
	if hit_something:
		is_finished = true
		add_collision_exception_with(body)
		$AnimatedSprite2D.play("hit")
		await $AnimatedSprite2D.animation_finished
		queue_free()
