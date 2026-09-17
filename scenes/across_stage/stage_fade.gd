class_name StageFade
extends Node2D

var fade_into_black = true
var fade_time = 2.0
var fade_amount = 0.0

signal fade_done

func _ready() -> void:
	$FadeSprite.self_modulate.a = 0.0 if fade_into_black else 1.0
	$FadeSprite.visible = true

func _process(delta: float) -> void:
	fade_amount += delta
	var directional_fade_amount = fade_amount
	if not fade_into_black:
		directional_fade_amount = fade_time - fade_amount
	directional_fade_amount /= fade_time
	$FadeSprite.self_modulate.a = clamp(directional_fade_amount,0,1)
	if fade_amount > fade_time:
		fade_done.emit()
		queue_free()
