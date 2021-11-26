extends KinematicBody

var player_in_area := false
var position := Vector2.ZERO
var direction := Vector2.ZERO
var intersection_position := Vector2.ZERO

func _on_Player_move_beetle(intersection_position_0) -> void:
	if player_in_area:
		if intersection_position_0 == Vector3.ZERO:
			direction = Vector2.ZERO
		else:
			position = Vector2(global_transform.origin.x, global_transform.origin.z)
			intersection_position = Vector2(intersection_position_0.x, intersection_position_0.z)
			var direction3D = (intersection_position_0 - global_transform.origin)
			direction = Vector2(direction3D.x, direction3D.z)


func _on_puzzle_area_body_entered(body: Node) -> void:
	if body is Player:
		player_in_area = true


func _on_puzzle_area_body_exited(body: Node) -> void:
	if body is Player:
		player_in_area = false
