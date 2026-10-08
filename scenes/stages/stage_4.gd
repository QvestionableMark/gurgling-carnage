extends Stage

const STAGE_WIDTH_MULTIPLIER: int = 10
const STAGE_EXIT_MARGIN: int = 100
const STAGE_EXIT_FADE_TIME: float = 1.0
const HAND_DAMAGE: int = 10
const TOOTH_DAMAGE: int = 25
const ACID_DAMAGE: int = 5
const COLLISION_END_LAG: float = 0.5
const HAND_KNOCKBACK: int = 1000
const TOOTH_KNOCKBACK: int = 750
const ACID_DAMAGE_INTERVAL: float = 0.5

var is_player_in_acid: bool = false
var is_fading: bool = false

func _ready() -> void:
	super()
	var fade: StageFade = STAGE_FADE.instantiate() as StageFade
	fade.fade_into_black = false
	add_child(fade)

func _process(_delta: float) -> void:
	# win condition:
	if player.position.x > Game.GAME_VIEW_SIZE.x * STAGE_WIDTH_MULTIPLIER + STAGE_EXIT_MARGIN and not is_fading:
		is_fading = true
		var fade: StageFade = STAGE_FADE.instantiate() as StageFade
		fade.fade_time = STAGE_EXIT_FADE_TIME
		add_child(fade)
		await fade.fade_done
		game.load_stage.call_deferred(stage_number + 1)

func _on_damage_area_body_shape_exited(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int) -> void:
	if body is Player:
		var shape_owner_id: int = $DamageArea.shape_find_owner(local_shape_index)
		var collider: Node2D = $DamageArea.shape_owner_get_owner(shape_owner_id) as Node2D
		if collider.is_in_group("acid"):
			is_player_in_acid = false

func _on_damage_area_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int) -> void:
	if body is Player:
		var shape_owner_id: int = $DamageArea.shape_find_owner(local_shape_index)
		var collider: Node2D = $DamageArea.shape_owner_get_owner(shape_owner_id) as Node2D
		if collider.is_in_group("hand"):
			body.take_damage(HAND_DAMAGE)
			body.end_lag += COLLISION_END_LAG
			body.external_velocity += -body.position.direction_to((collider as CollisionPolygon2D).polygon[1] + collider.global_position) * HAND_KNOCKBACK
		if collider.is_in_group("tooth"):
			body.take_damage(TOOTH_DAMAGE)
			body.end_lag += COLLISION_END_LAG
			body.input_velocity = Vector2.ZERO
			body.external_velocity += -body.position.direction_to((collider as CollisionPolygon2D).polygon[1] + collider.global_position) * TOOTH_KNOCKBACK
		if collider.is_in_group("acid"):
			is_player_in_acid = true
			while is_player_in_acid:
				body.take_damage(ACID_DAMAGE)
				await get_tree().create_timer(ACID_DAMAGE_INTERVAL).timeout
