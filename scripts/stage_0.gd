extends Stage


@onready var projectilePS : PackedScene = preload("res://scenes/in_game/projectile.tscn")

func _on_timer_timeout() -> void:
	if randf() < 1.0/3.0:
		var projectile = projectilePS.instantiate() as Area2D
		add_child(projectile)
