extends Area


func _on_puzzle_area_body_entered(body: Node) -> void:
	if body is Player:
		Global.emit_signal("puzzle_entered",self.global_transform)


func _on_puzzle_area_body_exited(body: Node) -> void:
	if body is Player:
		Global.emit_signal("puzzle_exited")
