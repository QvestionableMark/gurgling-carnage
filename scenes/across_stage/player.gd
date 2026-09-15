class_name Player
extends CharacterBody2D

var game : Game

const JUMP_VELOCITY = -750
const SPEED = 400
const ACCELARATION = 800

var endLag = 0
var external_velocity = Vector2.ZERO
var input_velocity = Vector2.ZERO

func _physics_process(delta):
	if game.persistent_data.health <= 0:
		$AnimatedSprite2D.stop()
		return
	endLag = clamp(endLag - delta, 0, 1)
	
	
	var effective_speed = SPEED
	
	
	
	if $DashTimer.time_left + endLag == 0 and Input.is_action_just_pressed("dash"):
		$DashTimer.start()
	if $DashTimer.time_left > 0:
		effective_speed *= 2.5


	input_velocity.x = 0
	if endLag == 0:
		if Input.is_action_pressed("move_left"):
			input_velocity.x -= effective_speed 
			$AnimatedSprite2D.scale.x = -abs($AnimatedSprite2D.scale.x)
		if Input.is_action_pressed("move_right"):
			input_velocity.x += effective_speed
			$AnimatedSprite2D.scale.x = abs($AnimatedSprite2D.scale.x)
	
	if not is_on_floor():
		if $AnimatedSprite2D.animation == "jump" and not $AnimatedSprite2D.is_playing():
			$AnimatedSprite2D.play("fall")
		if is_on_ceiling():
			input_velocity.y *= -1
			external_velocity.y *= -1
		input_velocity += get_gravity() * delta
	else:
		if endLag == 0 and Input.is_action_just_pressed("jump"):
			input_velocity.y = JUMP_VELOCITY
			$AnimatedSprite2D.play("jump")
		else:
			input_velocity.y = 0
			if input_velocity.x != 0:
				$AnimatedSprite2D.play("run")
			else:
				$AnimatedSprite2D.play("idle")
	
	
	velocity = input_velocity + external_velocity
	
	move_and_slide()
	
	external_velocity = external_velocity.move_toward(Vector2.ZERO,ACCELARATION * delta)

func take_damage(damage):
	game.persistent_data.health -= damage
	game.hud_update.emit()
	game.save_persistent_data()
	if game.persistent_data.health <= 0:
		game.handle_death()

func _on_dash_timer_timeout() -> void:
	endLag += 0.5
	input_velocity = Vector2.ZERO
