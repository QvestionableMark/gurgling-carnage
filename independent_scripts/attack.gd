class_name Attack
extends AnimatableBody2D

signal finished()

@export var is_parryable: bool = false
@export var hit_damage: int = 0

var speed: float = 550.0
var direction: Vector2

var is_finished: bool = false
var has_hit_player: bool = false

var has_been_parried: bool = false
var has_parry_indicator: bool

func initialize() -> void:
	pass

func handle_parry(_player: Player) -> void:
	print("No parry handling was added, is this a mistake?")
