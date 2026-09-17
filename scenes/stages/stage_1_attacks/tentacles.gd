extends Attack

var is_finished = false
var is_going_back = false
signal finished

func _ready() -> void:
	position = Vector2(115,-70)

func _process(delta: float) -> void:
	if $AnimatedSprite2D.frame == 0:
		if is_going_back:
			finished.emit()
			queue_free()
	if $AnimatedSprite2D.frame == 8:
		is_going_back = true

func _on_hit_area_body_entered(body: Node2D) -> void:
	if is_finished:
		return 
	
	var hit_something = false
	if body is Player:
		body.take_damage(hit_damage)
		body.end_lag += 1
		body.external_velocity += Vector2(-1,1) * 450
		hit_something = true
		is_finished = true
