extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if Input.is_action_just_pressed("pause") or Input.is_action_just_pressed("jump"):
		_on_VideoPlayer_finished()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VideoPlayer_finished():
	get_tree().change_scene("res://World/full_scenario/HIVEMIND WORLD_03.tscn")


#func _on_VideoPlayer_gui_input(event):
#	if event is InputEventKey:
#		if event.pressed and event.scancode == KEY_ESCAPE:
#			_on_VideoPlayer_finished()
#		print(event.as_text())
#
#
#func _on_Area2D_input_event(viewport, event, shape_idx):
#	if event is InputEventKey:
#		if event.pressed and event.scancode == KEY_ESCAPE:
#			_on_VideoPlayer_finished()
#		print(event.as_text())
#
#
#func _on_IntroVideo_gui_input(event):
#	if event is InputEventKey:
#		if event.pressed and event.scancode == KEY_ESCAPE:
#			_on_VideoPlayer_finished()
#		print(event.as_text())
		
func _unhandled_input(event):
	if Input.is_action_just_pressed("skip"):
		_on_VideoPlayer_finished()
#
#	if event is InputEventKey:
#		if event.pressed and event.scancode == KEY_ESCAPE:
#			_on_VideoPlayer_finished()
