extends Area


func _on_Lymph_body_entered(body: Node) -> void:
	if body is Player:
		Global.emit_signal("lymph_picked")
		AudioEngine.play_sfx("victory")
		queue_free()
