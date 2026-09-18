extends Stage

func _ready() -> void:
	update_data()
	var fade = STAGE_FADE.instantiate() as StageFade
	fade.fade_into_black = false
	$CanvasLayer.add_child(fade)
	await fade.fade_done
	await get_tree().create_timer(5).timeout
	var fade2 = STAGE_FADE.instantiate() as StageFade
	$CanvasLayer.add_child(fade2)
	await fade2.fade_done
	is_active = false
	game.handle_win()
	
