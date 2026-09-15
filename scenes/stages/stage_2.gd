extends Stage

@onready var PROJECTILE : PackedScene = preload("res://scenes/stages/stage_1_attacks/projectile.tscn")

func _on_timer_timeout() -> void:
	if randf() < 1.0/3.0:
		var projectile = PROJECTILE.instantiate() as AnimatableBody2D
		add_child(projectile)
