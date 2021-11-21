extends KinematicBody

var direction := Vector2.ZERO

func _on_Player_move_beetle(position) -> void:
	if position == Vector3.ZERO:
		direction = Vector2.ZERO
	else:
		var direction3D = (position - global_transform.origin)
		direction = Vector2(direction3D.x, direction3D.z)
