extends Control


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("jump"):
		_on_VideoPlayer_finished()


func _on_VideoPlayer_finished():
	get_tree().change_scene("res://World/full_scenario/HIVEMIND WORLD_03.tscn")
