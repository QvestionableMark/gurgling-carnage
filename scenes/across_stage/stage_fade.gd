class_name StageFade
extends Node2D

signal fade_done()

var fade_into_black: bool = true
var fade_duration: float = 0.0
var elapsed_fade_time: float = 0.0

func _ready() -> void:
	$FadeSprite.self_modulate.a = 0.0 if fade_into_black else 1.0
	$FadeSprite.visible = true

func _process(delta: float) -> void:
	if fade_duration <= 0.0:
		$FadeSprite.self_modulate.a = 1.0 if fade_into_black else 0.0
		fade_done.emit()
		queue_free()
		return

	elapsed_fade_time += delta
	var fade_alpha: float = elapsed_fade_time
	if not fade_into_black:
		fade_alpha = fade_duration - elapsed_fade_time
	fade_alpha /= fade_duration
	$FadeSprite.self_modulate.a = clampf(fade_alpha, 0.0, 1.0)
	if elapsed_fade_time > fade_duration:
		fade_done.emit()
		queue_free()
