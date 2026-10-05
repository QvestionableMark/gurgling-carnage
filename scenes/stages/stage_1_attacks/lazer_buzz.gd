extends Attack


var is_finished = false

func _ready() -> void:
	pass

func _on_hit_area_body_entered(body: Node2D) -> void:
	
	if is_finished:
		return 
	
	if body is Player:
		
		body.take_damage(hit_damage)
		body.end_lag += 1
		
		body.external_velocity += Vector2(-1,1) * 450
		
		
		is_finished = true
		
		


func finished_attacking() -> void:
	queue_free() 

	pass 
