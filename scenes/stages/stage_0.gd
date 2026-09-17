extends Stage

func _process(_delta: float) -> void:
	# win condition:
	if player.position.x > 1800:
		game.load_stage(1)
