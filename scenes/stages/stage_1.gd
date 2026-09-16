extends Stage

@onready var PROJECTILE : PackedScene = preload("res://scenes/stages/stage_1_attacks/tooth.tscn")

var is_ready = false

func  _ready() -> void:
	super()
	await $AnimatedSprite2D.animation_finished
	$AnimatedSprite2D.play("default")
	is_ready = true

func _on_timer_timeout() -> void:
	if is_ready and randf() < 1.0/3.0:
		var projectile = PROJECTILE.instantiate() as AnimatableBody2D
		add_child(projectile)
