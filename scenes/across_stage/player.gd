class_name Player
extends CharacterBody2D

var game : Game
@onready var PARRY_PARTICLE : PackedScene = preload("res://scenes/across_stage/parry_particle.tscn")
@onready var on_hit_sound = $on_hit_sound
@onready var death_sound =$death_sound
@onready var run_sound = $run_sound
@onready var jump_sound = $jump_sound
@onready var dash_sound = $dash_sound
@onready var parry_sound = $parry_sound
var potential_parryable_attacks : Array[Node2D] = []

const JUMP_VELOCITY = -750
const BOUNCINESS = 0.75
const SPEED = 400
const ACCELARATION = 800

var end_lag = 0
var external_velocity = Vector2.ZERO
var input_velocity = Vector2.ZERO
var gravity = Vector2(0,980)
var fast_fall_gravity = Vector2(0,980)


var is_running = false
var is_falling = false
var is_fast_falling = false
var is_jumping = false
var is_dashing = false
var is_parrying = false

func _physics_process(delta):
	end_lag = clamp(end_lag - delta, 0, 1)
	modulate = Color(clamp(modulate.r + delta,0,1), clamp(modulate.g + delta,0,1), clamp(modulate.b + delta,0,1))
	
	var effective_speed = SPEED
	
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
		dash_sound.play()
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
			end_lag += 0.3
			parry_sound.play()
			var parry_particle_instance : GPUParticles2D = PARRY_PARTICLE.instantiate()
			attack.handle_parry(self)
			parry_particle_instance.position = $AnimatedSprite2D/ParryableArea.global_position + (attack.global_position - global_position)/2
			game.add_child(parry_particle_instance)
		potential_parryable_attacks.clear()
	
	input_velocity.x = 0
	if (is_on_ceiling() or is_on_floor()) and game.current_stage.is_free_fall:
		input_velocity.y = 0
	if end_lag == 0:
		if Input.is_action_pressed("move_left"):
			input_velocity.x -= effective_speed 
			$AnimatedSprite2D.scale.x = -abs($AnimatedSprite2D.scale.x)
			run_sound.play()
		if Input.is_action_pressed("move_right"):
			input_velocity.x += effective_speed
			$AnimatedSprite2D.scale.x = abs($AnimatedSprite2D.scale.x)
			run_sound.play()
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
		if end_lag == 0 and Input.is_action_just_pressed("jump"):
			input_velocity.y = JUMP_VELOCITY
			is_jumping = true
			jump_sound.play()
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
	elif is_fast_falling:
		$AnimatedSprite2D.play("fast_fall")
	elif is_falling:
		$AnimatedSprite2D.play("fall")
	elif is_running:
		$AnimatedSprite2D.play("run")
	else:
		$AnimatedSprite2D.play("idle")

func take_damage(damage):
	if game.persistent_data.hardmode:
		damage *= 2
	game.persistent_data.health -= damage
	game.hud_update.emit()
	modulate = Color.RED
	on_hit_sound.play()
	if game.persistent_data.health <= 0:
		death_sound.play()
		await death_sound.finished
		game.handle_death()
		
	else:
		game.save_persistent_data()

func _on_dash_timer_timeout() -> void:
	end_lag += 0.2
	input_velocity = Vector2.ZERO
	$RollingCollision.disabled = true
	$NonRollingCollision.disabled = false

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
