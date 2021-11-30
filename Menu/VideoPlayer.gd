extends VideoPlayer


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		AudioEngine.fade_out(1.0)
		get_tree().change_scene("res://World/full_scenario/HIVEMIND WORLD_03.tscn")

func _on_VideoPlayer_finished() -> void:
	AudioEngine.fade_out(1.0)
	get_tree().change_scene("res://World/full_scenario/HIVEMIND WORLD_03.tscn")
