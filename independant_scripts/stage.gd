class_name Stage
extends Node2D

@onready var game : Game = get_tree().get_first_node_in_group("game")
var player : Player
@export var stage_number : int
@export var player_start_position : Vector2

func _ready() -> void:
	player = load("res://scenes/across_stage/player.tscn").instantiate() as Player
	add_child(player)
	player.position = player_start_position
	game.current_player = player
	player.game = game
