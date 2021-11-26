extends Label


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.DEBUG:
		visible = true
		Global.connect("debug_write",self,"on_debug_write")
	else:
		visible = false

func on_debug_write(text_to_write)->void:
	text = text_to_write
