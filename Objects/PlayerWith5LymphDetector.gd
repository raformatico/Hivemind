extends Area


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_PlayerWith5LymphDetector_body_entered(body: Node) -> void:
	if body is Player:
		Global.player_in_area_final = true
		if Global.lymph_completed:
			get_tree().change_scene("videofinal")


func _on_PlayerWith5LymphDetector_body_exited(body: Node) -> void:
	if body is Player:
		Global.player_in_area_final = false
