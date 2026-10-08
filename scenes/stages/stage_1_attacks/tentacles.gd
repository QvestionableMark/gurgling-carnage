class_name Tentacles
extends Attack

const SCALE_RANGE: float = 0.4
const MIN_SCALE: float = 0.60
const TENTACLE_VARIANT_COUNT: int = 3
const HIT_END_LAG: int = 1
const HIT_KNOCKBACK: int = 750

var is_retracting: bool = false

var tentacle_variant_index: int
var tentacle_variants: Dictionary[int, Dictionary] = {
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
	scale = Vector2.ONE * (randf() * SCALE_RANGE + MIN_SCALE)
	tentacle_variant_index = randi() % TENTACLE_VARIANT_COUNT
	$TentaclesSprite.play(tentacle_variants[tentacle_variant_index].name)
	$CollisionAnimation.play(tentacle_variants[tentacle_variant_index].name)

func _process(_delta: float) -> void:
	if is_retracting and $TentaclesSprite.frame == 0:
		finished.emit()
		queue_free()
	if $TentaclesSprite.frame == tentacle_variants[tentacle_variant_index].last_frame:
		is_retracting = true

func _on_hit_area_body_entered(body: Node2D) -> void:
	if has_hit_player:
		return

	if body is Player:
		body.take_damage(hit_damage)
		body.end_lag += HIT_END_LAG
		body.external_velocity += $HitArea/TentacleCollision.global_position.direction_to(body.global_position) * HIT_KNOCKBACK
		has_hit_player = true
