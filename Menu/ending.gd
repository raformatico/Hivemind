extends VideoPlayer


func _ready() -> void:
	AudioEngine.stop_sfx()

func _on_VideoPlayer_finished() -> void:
	get_tree().change_scene("res://Menu/Menu.tscn")
