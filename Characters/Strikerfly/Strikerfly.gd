extends KinematicBody

var player_in_area : bool = false
var direction := Vector2.ZERO
var intersection_position := Vector2.ZERO
var position := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_Player_move_puzzle(position_local) -> void:
	if player_in_area:
		if position_local == Vector3.ZERO:
			direction = Vector2.ZERO
		else:
			position = Vector2(global_transform.origin.x, global_transform.origin.z)
			intersection_position = Vector2(position_local.x, position_local.z)
			var direction_intersection = (position_local - global_transform.origin)
			direction = Vector2(direction_intersection.x, direction_intersection.z).normalized()


func _on_puzzle_area_body_entered(body: Node) -> void:
	if body is Player:
		player_in_area = true


func _on_puzzle_area_body_exited(body: Node) -> void:
	if body is Player:
		player_in_area = false

