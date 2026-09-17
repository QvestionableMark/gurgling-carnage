class_name StageFade
extends Node2D

var fade_into_black = true
var fade_time = 2.0
var fade_amount = 0.0

signal fade_done

func _process(delta: float) -> void:
	fade_amount += delta
	var directional_fade_amount = fade_amount
	if not fade_into_black:
		directional_fade_amount = fade_time - fade_amount
	directional_fade_amount /= fade_time
	$Sprite2D.self_modulate = Color(0,0,0,directional_fade_amount)
	if directional_fade_amount >= 1:
		fade_done.emit()
