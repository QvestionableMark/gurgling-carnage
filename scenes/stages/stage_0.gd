extends Stage

var is_lever_interactable = false

func _process(_delta: float) -> void:
	if is_lever_interactable and Input.is_action_just_pressed("interact"):
		if game.persistent_data.hardmode:
			$Lever/Stick.rotate(-PI/2)
			$Sign/Board/Status.text = "Status: OFF"
		else:
			$Lever/Stick.rotate(PI/2)
			$Sign/Board/Status.text = "Status: ON"
		game.persistent_data.hardmode = not game.persistent_data.hardmode
	# win condition:
	if player.position.x > 1800:
		game.load_stage(1)

func _on_lever_area_body_entered(body: Node2D) -> void:
	if body is Player:
		is_lever_interactable = true


func _on_lever_area_body_exited(body: Node2D) -> void:
	if body is Player:
		is_lever_interactable = false
