extends AnimatableBody2D

var direction
const SPEED = 300

func _ready() -> void:
	sync_to_physics = false
	await get_tree().physics_frame
	position = Vector2(1920, 1080/8*5)
	var target = Vector2(0,(0.25 + randf() / 2) * 1080)
	look_at(target)
	direction = position.direction_to(target)
	sync_to_physics = true
	await get_tree().physics_frame
	visible = true

func _physics_process(delta: float) -> void:
	position += direction * SPEED * delta

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(15)
		
		add_collision_exception_with(body)
		body.endLag += 0.5
		body.external_velocity += position.direction_to(body.position) * 1000
		queue_free()
