extends Attack

signal finished




var is_finished = false

func _ready() -> void:
	$AnimationPlayer.play("lazer_buzz")
	$AnimationPlayer.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_hit_area_body_entered(body: Node2D) -> void:
	
		
	if body is Player:
		if is_finished:
			return
		body.take_damage(hit_damage)
		body.end_lag += 1
		body.external_velocity += Vector2(-1, 1) * 450
		is_finished = true

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "lazer_buzz":
		finished_attacking()

func finished_attacking() -> void:
	finished.emit() 
	queue_free()
