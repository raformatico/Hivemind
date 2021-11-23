extends Control

func show_cursor() -> void:
	set_visible(true)


func hide_cursor() -> void:
	set_visible(false)


func _ready() -> void:
	
	pass # Replace with function body.


func _on_Player_in_mind() -> void:
	show_cursor()

func _on_Player_out_mind() -> void:
	hide_cursor()
