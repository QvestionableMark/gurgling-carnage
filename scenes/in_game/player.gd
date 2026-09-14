class_name Player
extends CharacterBody2D
const JUMP_VELOCITY = -500
const SPEED = 400
const ACCELARATION = 800

func _physics_process(delta):
	velocity.x=0	
	
	if Input.is_key_pressed (KEY_A):
		velocity.x = -SPEED
	if Input.is_key_pressed (KEY_D):
		velocity.x = SPEED
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_key_pressed (KEY_W) and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	
	
	

	move_and_slide()
