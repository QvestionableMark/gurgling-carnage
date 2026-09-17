class_name Player
extends CharacterBody2D

var game : Game
@onready var PARRY_PARTICLE : PackedScene = preload("res://scenes/across_stage/parry_particle.tscn")
var potential_parryable_attacks : Array[Node2D] = []

const JUMP_VELOCITY = -750
const GRAVITY_FALL_MULTIPLER = 2
const BOUNCINESS = 0.75
const SPEED = 400
const ACCELARATION = 800

var end_lag = 0
var external_velocity = Vector2.ZERO
var input_velocity = Vector2.ZERO

var is_running = false
var is_falling = false
var is_jumping = false
var is_dashing = false
var is_parrying = false

func _physics_process(delta):
	end_lag = clamp(end_lag - delta, 0, 1)
	modulate = Color(clamp(modulate.r + delta,0,1), clamp(modulate.g + delta,0,1), clamp(modulate.b + delta,0,1))
	
	var effective_speed = SPEED
	
	is_running = false
	is_falling = false
	
	if $DashTimer.time_left + end_lag == 0 and Input.is_action_just_pressed("dash"):
		$DashTimer.start()
		is_dashing = true
		is_jumping = false
		input_velocity.y = 0
		$RollingCollision.disabled = false
		$NonRollingCollision.disabled = true
	if $DashTimer.time_left > 0:
		effective_speed *= 2.5

	if $ParryTimer.time_left + end_lag == 0 and Input.is_action_just_pressed("parry"):
		$ParryTimer.start()
		is_parrying = true
		is_jumping = false
		is_dashing = false
		for attack in potential_parryable_attacks:
			if not is_instance_valid(attack) or not attack.is_parryable or not $AnimatedSprite2D/ParryableArea.overlaps_body(attack):
				continue
			var parry_particle_instance : GPUParticles2D = PARRY_PARTICLE.instantiate()
			attack.handle_parry(self)
			parry_particle_instance.position = $AnimatedSprite2D/ParryableArea.global_position + (attack.global_position - global_position)/2
			game.add_child(parry_particle_instance)
		potential_parryable_attacks.clear()
	
	input_velocity.x = 0
	if end_lag == 0:
		if Input.is_action_pressed("move_left"):
			input_velocity.x -= effective_speed 
			$AnimatedSprite2D.scale.x = -abs($AnimatedSprite2D.scale.x)
		if Input.is_action_pressed("move_right"):
			input_velocity.x += effective_speed
			$AnimatedSprite2D.scale.x = abs($AnimatedSprite2D.scale.x)
	if input_velocity.x != 0:
		is_running = true
	if not is_on_floor():
		if velocity.y != 0:
			is_falling = true
		if is_on_ceiling():
			input_velocity.y *= -BOUNCINESS
			external_velocity.y *= -BOUNCINESS
		if (input_velocity.y < 0):
			input_velocity += get_gravity() * delta
		else:
			input_velocity += get_gravity() * GRAVITY_FALL_MULTIPLER * delta
	else:
		if end_lag == 0 and Input.is_action_just_pressed("jump"):
			input_velocity.y = JUMP_VELOCITY
			is_jumping = true
		else:
			input_velocity.y = 0
	
	velocity = input_velocity + external_velocity
	
	move_and_slide()
	resolve_animation()
	
	external_velocity = external_velocity.move_toward(Vector2.ZERO,ACCELARATION * delta)
	
func resolve_animation():
	if is_parrying:
		$AnimatedSprite2D.play("parry")
	elif is_dashing:
		$AnimatedSprite2D.play("dash")
	elif is_jumping:
		$AnimatedSprite2D.play("jump")
	elif is_falling:
		$AnimatedSprite2D.play("fall")
	elif is_running:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")

func take_damage(damage):
	game.persistent_data.health -= damage
	game.hud_update.emit()
	modulate = Color.RED
	if game.persistent_data.health <= 0:
		game.handle_death()
	else:
		game.save_persistent_data()

func _on_dash_timer_timeout() -> void:
	end_lag += 0.2
	input_velocity = Vector2.ZERO
	$RollingCollision.disabled = true
	$NonRollingCollision.disabled = false

func _on_parry_timer_timeout() -> void:
	end_lag += 0.3


func _on_animated_sprite_2d_animation_finished() -> void:
	if $AnimatedSprite2D.animation == "jump":
		is_jumping = false
	elif $AnimatedSprite2D.animation == "dash":
		is_dashing = false
	elif $AnimatedSprite2D.animation == "parry":
		is_parrying = false


func _on_parryable_area_body_shape_entered(_body_rid: RID, body: Node2D, body_shape_index: int, _local_shape_index: int) -> void:
	var body_shape_owner = body.shape_find_owner(body_shape_index)
	var body_shape_node = body.shape_owner_get_owner(body_shape_owner)

	if body_shape_node.is_in_group("parryable"):
		potential_parryable_attacks.append(body)
