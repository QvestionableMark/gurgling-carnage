extends Attack

var is_finished = false
var is_going_back = false
var chosen_tentacle
signal finished

var tentacles = {
	0: {
		name = "high",
		last_frame = 10
	},
	1: {
		name = "middle",
		last_frame = 8
	},
	2: {
		name = "low",
		last_frame = 11
	}
}

func _ready() -> void:
	scale = Vector2.ONE * (randf() * 0.4 + 0.60)
	chosen_tentacle = randi() % 3
	$AnimatedSprite2D.play(tentacles[chosen_tentacle].name)
	$CollisionAnimation.play(tentacles[chosen_tentacle].name)

func _process(_delta: float) -> void:
	if is_going_back and $AnimatedSprite2D.frame == 0:
		finished.emit()
		queue_free()
	if $AnimatedSprite2D.frame == tentacles[chosen_tentacle].last_frame:
		is_going_back = true

func _on_hit_area_body_entered(body: Node2D) -> void:
	if is_finished:
		return 
	
	if body is Player:
		body.take_damage(hit_damage)
		body.end_lag += 1
		body.external_velocity += $HitArea/TentacleCollision.global_position.direction_to(body.global_position) * 750
		is_finished = true
