extends Attack

const SPEED = 200 

var velocity
var is_finished = false

func _ready() -> void:
	
	var drop_direction = Vector2(randf_range(-0.1, 0.1), 1.0).normalized()
	
	
	velocity = drop_direction * SPEED
	visible = true

func _physics_process(delta: float) -> void:
	if not is_finished:
		
		velocity += get_gravity() * delta
		
		
		
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
		
		

		queue_free()
