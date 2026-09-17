class_name Stage
extends Node2D

@onready var STAGE_FADE : PackedScene = preload("res://scenes/across_stage/stage_fade.tscn")

@onready var game : Game = get_tree().get_first_node_in_group("game")
var player : Player
@export var stage_number : int
@export var player_start_position : Vector2
@export var is_free_fall : bool
@export var boss_health : int
var boss_current_health
var is_active = false

func _ready() -> void:
	update_data()
	spawn_player()

func update_data():
	game.persistent_data.checkpoint = stage_number
	if game.persistent_data.hardmode:
		boss_health *= 2
	boss_current_health = boss_health
	
func spawn_player():
	player = load("res://scenes/across_stage/player.tscn").instantiate() as Player
	add_child(player)
	player.position = player_start_position
	game.current_player = player
	player.game = game
