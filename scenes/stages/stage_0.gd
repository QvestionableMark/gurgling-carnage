extends Stage

const STAGE_END_X: int = 1800

func _process(_delta: float) -> void:
	# win condition:
	if player.position.x > STAGE_END_X:
		game.load_stage(1)
