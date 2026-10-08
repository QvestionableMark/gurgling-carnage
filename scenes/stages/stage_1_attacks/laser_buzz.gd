class_name LaserBuzz
extends Attack

signal finished()

const HIT_END_LAG: int = 1
const HIT_KNOCKBACK: int = 450

var is_finished: bool = false

func _ready() -> void:
	$LaserBuzzAnimation.play("laser_buzz")
	$LaserBuzzAnimation.connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_hit_area_body_entered(body: Node2D) -> void:
	if body is Player:
		if is_finished:
			return
		body.take_damage(hit_damage)
		body.end_lag += HIT_END_LAG
		body.external_velocity += Vector2(-1, 1) * HIT_KNOCKBACK
		is_finished = true

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "laser_buzz":
		finished_attacking()

func finished_attacking() -> void:
	finished.emit()
	queue_free()
