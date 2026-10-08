extends Attack

const LEFT_SPAWN_CHANCE: float = 0.5
const LEFT_SPAWN_X: float = 0.1
const RIGHT_SPAWN_X: float = 0.9
const FIRING_ANIMATION_SPEED_MULTIPLIER: int = 10

var has_fired: bool = false

func _ready() -> void:
	var target_position: Vector2
	if randf() < LEFT_SPAWN_CHANCE:
		position = Vector2(Game.GAME_VIEW_SIZE.x * LEFT_SPAWN_X, randf() * Game.GAME_VIEW_SIZE.y)
		target_position = Vector2(Game.GAME_VIEW_SIZE.x, randf() * Game.GAME_VIEW_SIZE.y)
	else:
		position = Vector2(Game.GAME_VIEW_SIZE.x * RIGHT_SPAWN_X, randf() * Game.GAME_VIEW_SIZE.y)
		target_position = Vector2(0, randf() * Game.GAME_VIEW_SIZE.y)

	look_at(target_position)
	visible = true

func _on_hit_area_body_entered(body: Node2D) -> void:
	var is_player_hit: bool = false
	if body is Player:
		body.take_damage(hit_damage)
		is_player_hit = true

	if is_player_hit:
		add_collision_exception_with(body)

func _on_piercing_sprite_animation_finished() -> void:
	if has_fired:
		queue_free()
		return

	has_fired = true
	$HitArea.monitoring = true
	$LaserAudio.play()
	$PiercingSprite.self_modulate = Color.WHITE
	$PiercingSprite.speed_scale *= FIRING_ANIMATION_SPEED_MULTIPLIER
	$PiercingSprite.play("default")
