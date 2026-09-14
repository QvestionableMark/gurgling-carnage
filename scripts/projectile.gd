extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = Vector2(1920,1080/2)
	look_at(Vector2(0,randf() * 1080))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	move_local_x(200 * delta)


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	print(body_rid,body,body_shape_index,local_shape_index)
	if body_shape_index == 1 and body is Player:
		print("hit")
