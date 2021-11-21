extends Control


func show_cursor() -> void:
	set_visible(true)


func hide_cursor() -> void:
	set_visible(false)


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("mind_trick"):
		show_cursor()
	
	if Input.is_action_just_released("mind_trick"):
		hide_cursor()
