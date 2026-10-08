extends Stage

const STAGE_ENTRY_FADE_DURATION: float = 2.0
const STAGE_EXIT_FADE_DURATION: float = 2.0

const ENDING_DURATION: float = 5.0

func _ready() -> void:
	update_data()
	var entry_fade: StageFade = STAGE_FADE.instantiate() as StageFade
	entry_fade.fade_duration = STAGE_ENTRY_FADE_DURATION
	entry_fade.fade_into_black = false
	$Stage6Layer.add_child(entry_fade)
	await entry_fade.fade_done
	await get_tree().create_timer(ENDING_DURATION).timeout
	var exit_fade: StageFade = STAGE_FADE.instantiate() as StageFade
	exit_fade.fade_duration = STAGE_EXIT_FADE_DURATION
	$Stage6Layer.add_child(exit_fade)
	await exit_fade.fade_done
	is_active = false
	game.handle_win()
