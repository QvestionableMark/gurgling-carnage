extends Stage

@onready var ROCK : PackedScene = preload ("res://scenes/stages/stage_3_attacks/rocks.tscn")

func _on_timer_timeout() -> void:
	if randf() < 1.0 / 3.0:
		
		var rock = ROCK.instantiate() 
		
		var random_x = randf_range(0, 1920) 
		
		
		rock.global_position = Vector2(random_x, -50) 
		
		add_child(rock)
