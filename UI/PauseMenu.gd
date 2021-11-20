extends Control


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_visible(false)


func show_me() -> void:
	set_visible(true)
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func hide_me() -> void:
	set_visible(false)
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(delta: float) -> void:
	if Input.is_action_pressed("pause"):
		show_me()


func _on_Button_pressed() -> void:
	hide_me()
