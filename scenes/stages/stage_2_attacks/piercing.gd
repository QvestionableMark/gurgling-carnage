extends Attack

var pre_fired = false

func _ready() -> void:
	var target
	if randf() < 0.5:
		position = Vector2(Game.GAME_VIEW_SIZE.x * 0.1,randf() * Game.GAME_VIEW_SIZE.y)
		target = Vector2(Game.GAME_VIEW_SIZE.x,randf() * Game.GAME_VIEW_SIZE.y)
	else:
		position = Vector2(Game.GAME_VIEW_SIZE.x * 0.9,randf() * Game.GAME_VIEW_SIZE.y)
		target = Vector2(0,randf() * Game.GAME_VIEW_SIZE.y)
		
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
	
	
