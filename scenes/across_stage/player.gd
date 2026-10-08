class_name Player
extends CharacterBody2D

const PARRY_PARTICLE: PackedScene = preload("res://scenes/across_stage/parry_particle.tscn")

const DASH_SPEED_MULTIPLIER: int = 3
const PARRY_SLOWMO_STRENGTH: float = 0.5
const PARRY_SLOWMO_DURATION: float = 0.2
const DEFAULT_GRAVITY: Vector2 = Vector2(0, 980)
const MAX_END_LAG: float = 1.0
const JUMP_VELOCITY: int = -750
const BOUNCINESS: float = 0.5
const SPEED: int = 400
const ACCELERATION: int = 800

var game: Game

var potential_parryable_attacks: Array[Attack] = []

var end_lag: float = 0.0

var external_velocity: Vector2 = Vector2.ZERO
var input_velocity: Vector2 = Vector2.ZERO
var gravity: Vector2 = DEFAULT_GRAVITY
var fast_fall_gravity: Vector2 = DEFAULT_GRAVITY

var is_running: bool = false
var is_falling: bool = false
var is_fast_falling: bool = false
var is_jumping: bool = false
var is_dashing: bool = false
var is_parrying: bool = false

func _physics_process(delta: float) -> void:
	if game.persistent_data.health <= 0:
		return
	end_lag = clampf(end_lag - delta, 0.0, MAX_END_LAG)
	modulate = Color(clampf(modulate.r + delta, 0.0, 1.0), clampf(modulate.g + delta, 0.0, 1.0), clampf(modulate.b + delta, 0.0, 1.0))

	var effective_speed: float = SPEED

	is_running = false
	is_falling = false
	is_fast_falling = false

	if $DashTimer.time_left + end_lag == 0 and Input.is_action_just_pressed("dash"):
		$DashTimer.start()
		is_dashing = true
		is_jumping = false
		input_velocity.y = 0
		$RollingCollision.disabled = false
		$NonRollingCollision.disabled = true
		$DashAudio.play()
	if is_dashing:
		effective_speed *= DASH_SPEED_MULTIPLIER

	if $ParryTimer.time_left + end_lag == 0 and Input.is_action_just_pressed("parry"):
		$ParryTimer.start()
		is_parrying = true
		is_jumping = false
		is_dashing = false
		var parried_anything: bool = false
		for attack: Attack in potential_parryable_attacks:
			if not is_instance_valid(attack) or not attack.is_parryable or not $PlayerSprite/ParryableArea.overlaps_body(attack):
				continue
			parried_anything = true
			$ParryAudio.play()
			var parry_particle_instance: CPUParticles2D = PARRY_PARTICLE.instantiate()
			attack.handle_parry(self)
			parry_particle_instance.position = $PlayerSprite/ParryableArea.global_position + (attack.global_position - global_position) / 2
			game.add_child(parry_particle_instance)
		if not parried_anything:
			$WhiffParryAudio.play()
		else:
			game.create_slowmo(PARRY_SLOWMO_STRENGTH, PARRY_SLOWMO_DURATION)

	input_velocity.x = 0
	if (is_on_ceiling() or is_on_floor()) and game.current_stage.is_free_fall:
		input_velocity.y = 0
	if end_lag == 0:
		if Input.is_action_pressed("move_left"):
			input_velocity.x -= effective_speed
			$PlayerSprite.scale.x = -abs($PlayerSprite.scale.x)
		if Input.is_action_pressed("move_right"):
			input_velocity.x += effective_speed
			$PlayerSprite.scale.x = abs($PlayerSprite.scale.x)
	if input_velocity.x != 0:
		is_running = true
	if not is_on_floor() or game.current_stage.is_free_fall:
		if velocity.y != 0 or game.current_stage.is_free_fall:
			is_falling = true
		if is_on_ceiling() and not game.current_stage.is_free_fall:
			input_velocity.y *= -BOUNCINESS
			external_velocity.y *= -BOUNCINESS
		if not Input.is_action_pressed("fast_fall"):
			input_velocity += gravity * delta
		else:
			is_fast_falling = true
			input_velocity += (gravity + fast_fall_gravity) * delta
	else:
		if end_lag == 0 and Input.is_action_pressed("jump"):
			input_velocity.y = JUMP_VELOCITY
			is_jumping = true
			$JumpAudio.play()
		else:
			input_velocity.y = 0
			if not $RunAudio.playing and input_velocity.x != 0:
				$RunAudio.play()

	velocity = input_velocity + external_velocity

	move_and_slide()
	resolve_animation()

	external_velocity = external_velocity.move_toward(Vector2.ZERO, ACCELERATION * delta)

func set_animation(animation: StringName) -> void:
	if $PlayerSprite.animation != animation:
		$PlayerSprite.play(animation)

func resolve_animation() -> void:
	if is_parrying:
		set_animation("parry")
	elif is_dashing:
		set_animation("dash")
	elif is_jumping:
		set_animation("jump")
	elif is_fast_falling:
		set_animation("fast_fall")
	elif is_falling:
		set_animation("fall")
	elif is_running:
		set_animation("run")
	else:
		set_animation("idle")

func take_damage(damage: float) -> void:
	if game.persistent_data.health <= 0:
		return
	if game.persistent_data.hardmode:
		damage *= Game.HARDMODE_MULTIPLIER
	game.persistent_data.health -= damage
	game.hud_update.emit()
	modulate = Color.RED
	$OnHitAudio.play()
	if game.persistent_data.health <= 0:
		$DeathAudio.play()
		game.handle_death()

	else:
		game.save_persistent_data()

func _on_player_sprite_animation_finished() -> void:
	if $PlayerSprite.animation == "jump":
		is_jumping = false
	elif $PlayerSprite.animation == "dash":
		is_dashing = false
		$RollingCollision.disabled = true
		$NonRollingCollision.disabled = false
	elif $PlayerSprite.animation == "parry":
		$RollingCollision.disabled = true
		$NonRollingCollision.disabled = false
		is_parrying = false
	resolve_animation()

func _on_parryable_area_body_shape_entered(_body_rid: RID, body: Node2D, body_shape_index: int, _local_shape_index: int) -> void:
	var body_shape_owner: int = body.shape_find_owner(body_shape_index)
	var body_shape_node: Node = body.shape_owner_get_owner(body_shape_owner)

	if body_shape_node.is_in_group("parryable") and not potential_parryable_attacks.has(body):
		potential_parryable_attacks.append(body)

func _on_parryable_area_body_shape_exited(_body_rid: RID, body: Node2D, body_shape_index: int, _local_shape_index: int) -> void:
	if not is_instance_valid(body):
		for index: int in range(potential_parryable_attacks.size() - 1, -1, -1):
			if not is_instance_valid(potential_parryable_attacks[index]):
				potential_parryable_attacks.remove_at(index)
		return

	var body_shape_owner: int = body.shape_find_owner(body_shape_index)
	var body_shape_node: Node = body.shape_owner_get_owner(body_shape_owner)

	if body_shape_node.is_in_group("parryable") and potential_parryable_attacks.has(body):
		potential_parryable_attacks.erase(body)
