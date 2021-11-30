extends StaticBody


onready var collision : CollisionShape = $lake_collision


func _ready() -> void:
	collision.disabled = true


func _on_Player_glide_started(glide_time) -> void:
	collision.disabled = false


func _on_Player_glide_restarted(reset_time) -> void:
	collision.disabled = true
