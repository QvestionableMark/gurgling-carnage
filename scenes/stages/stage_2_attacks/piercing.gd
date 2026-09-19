extends Attack

var pre_fired = false

func _ready() -> void:
	var target
	if randf() < 0.5:
		position = Vector2(200,randf() * 1080)
		target = Vector2(1920,randf() * 1080)
	else:
		position = Vector2(1720,randf() * 1080)
		target = Vector2(0,randf() * 1080)
		
	look_at(target)
	visible = true

func _on_hit_area_body_entered(body: Node2D) -> void:
	var hit_something = false
	if body is Player:
		body.take_damage(hit_damage)
		hit_something = true
	
	if hit_something:
		add_collision_exception_with(body)


func _on_animated_sprite_2d_animation_finished() -> void:
	if pre_fired:
		queue_free()
		return
	
	
	pre_fired = true
	$HitArea.monitoring = true
	$LaserAudio.play()
	$AnimatedSprite2D.self_modulate = Color.WHITE
	$AnimatedSprite2D.speed_scale *= 10
	$AnimatedSprite2D.play("default")
	
	
