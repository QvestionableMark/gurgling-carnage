extends Attack

var speed = 750
var direction

func _ready() -> void:
	sync_to_physics = false
	await get_tree().physics_frame
	position = Vector2(1920, 1080.0/8*5)
	var target = Vector2(0,(0.25 + randf() / 2) * 1080)
	look_at(target)
	direction = position.direction_to(target)
	sync_to_physics = true
	await get_tree().physics_frame
	visible = true

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func handle_parry(player : Player):
	sync_to_physics = false
	direction = player.global_position.direction_to(global_position)
	look_at(global_position + direction)
	sync_to_physics = true
	been_parried = true

func _on_hit_area_body_entered(body: Node2D) -> void:
	if not been_parried and body is Player:
		body.take_damage(hit_damage)
		speed = 0
		add_collision_exception_with(body)
		body.end_lag += 0.5
		body.external_velocity += position.direction_to(body.position) * 1000
		$AnimatedSprite2D.play("hit")
		await $AnimatedSprite2D.animation_finished
		queue_free()
