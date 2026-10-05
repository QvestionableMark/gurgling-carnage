extends Stage

var is_player_in_acid = false

func _process(_delta: float) -> void:
	# win condition:
	if player.position.x > 1920*10 + 100:
		game.load_stage(stage_number+1)

func _on_damage_area_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is Player:
		var shape_owner_id = $DamageArea.shape_find_owner(local_shape_index)
		var collider = $DamageArea.shape_owner_get_owner(shape_owner_id)
		if collider.is_in_group("acid"):
			is_player_in_acid = false

func _on_damage_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is Player:
		var shape_owner_id = $DamageArea.shape_find_owner(local_shape_index)
		var collider = $DamageArea.shape_owner_get_owner(shape_owner_id)
		print(collider.get_groups())
		if collider.is_in_group("hand"):
			body.take_damage(10)
			body.end_lag += 0.5
			body.external_velocity += -body.position.direction_to(collider.polygon[1] + collider.global_position) * 1000
		if collider.is_in_group("tooth"):
			body.take_damage(25)
			body.end_lag += 0.5
			body.external_velocity += -body.position.direction_to(collider.polygon[1] + collider.global_position) * 750
		if collider.is_in_group("acid"):
			is_player_in_acid = true
			while is_player_in_acid:
				body.take_damage(5)
				await get_tree().create_timer(0.5).timeout
