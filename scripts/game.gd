class_name Game
extends Node2D

@export var stages : Array[String]
var current_stage : Stage

func load_stage(stage_to_load):
	if (current_stage):
		current_stage.queue_free()
	var new_stage = load(stage_to_load).instantiate() as Stage
	add_child(new_stage)
	current_stage = new_stage
	pass
