extends Stage

const ENDING_DURATION: float = 5.0

func _ready() -> void:
	update_data()
	var fade: StageFade = STAGE_FADE.instantiate() as StageFade
	fade.fade_into_black = false
	$Stage6Layer.add_child(fade)
	await fade.fade_done
	await get_tree().create_timer(ENDING_DURATION).timeout
	var fade2: StageFade = STAGE_FADE.instantiate() as StageFade
	$Stage6Layer.add_child(fade2)
	await fade2.fade_done
	is_active = false
	game.handle_win()
