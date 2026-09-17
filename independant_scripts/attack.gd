class_name Attack
extends AnimatableBody2D

@export var is_parryable = false
var been_parried = false
var has_parry_indicator
@export var hit_damage = 0

func initialize():
	pass

func handle_parry(_player):
	print("No parry handling was added, is this a mistake?")
