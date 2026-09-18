extends Attack

var speed = 200 
var direction
var is_finished = false

func _ready() -> void:
	var target = Vector2((0.4 + randf() / 5)*1920, 1080/2)
	look_at(target)
	direction = position.direction_to(target)
	
	rotation = direction.angle()
	
	sync_to_physics = true
	await get_tree().physics_frame
	visible = true

func _physics_process(delta: float) -> void:
	if not is_finished:
		position += direction * speed * delta

func handle_parry(player : Player):
	sync_to_physics = false
	direction.x = (-global_position.direction_to(player.global_position)).x
	rotation = direction.angle()
	sync_to_physics = true
	been_parried = true

func _on_hit_area_body_entered(body: Node2D) -> void:
	if is_finished:
		return
	
	var hit_something = false
	if body is Player:
		body.take_damage(hit_damage)
		body.end_lag += 0.7
		hit_something = true

	if body.is_in_group("solid"):
		hit_something = true
	
	if been_parried and body.is_in_group("boss"):
		body.get_parent().take_damage(hit_damage)
		hit_something = true
		
	
	if hit_something:
		is_finished = true
		add_collision_exception_with(body)
		
		

		queue_free()
