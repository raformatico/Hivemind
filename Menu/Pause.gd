extends Control

onready var play_selector := $SelectorPlay
onready var play_options := $SelectorOptions
onready var play_exit := $SelectorExit
onready var background_keys := $BackgroundKeys


func _ready() -> void:
	$Play.grab_focus()
	background_keys.visible = false
	visible = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if visible:
			hide_me()
		elif background_keys.visible:
			$BackgroundKeys.visible = false
			hide_back_button()
			show_buttons()
		else:
			show_me()

func show_me() -> void:
	set_visible(true)
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$Play.grab_focus()


func hide_buttons() -> void:
	$Play.visible = false
	$Options.visible = false
	$Exit.visible = false

func show_buttons() -> void:
	$Play.visible = true
	$Play.grab_focus()
	$Options.visible = true
	$Exit.visible = true


func show_back_button() -> void:
	$Back.visible = true
	$Back.grab_focus()
	$SelectorBack.visible = true


func hide_back_button() -> void:
	$Back.visible = false
	$SelectorBack.visible = false


func hide_me() -> void:
	set_visible(false)
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_Play_pressed() -> void:
	hide_me()


func _on_Exit_pressed() -> void:
	get_tree().quit()


func _on_Options_pressed() -> void:
	hide_buttons()
	background_keys.visible = true
	show_back_button()
	


func _on_Play_focus_entered() -> void:
	play_selector.visible = true


func _on_Options_focus_entered() -> void:
	play_options.visible = true


func _on_Exit_focus_entered() -> void:
	play_exit.visible = true


func _on_Play_focus_exited() -> void:
	play_selector.visible = false


func _on_Options_focus_exited() -> void:
	play_options.visible = false


func _on_Exit_focus_exited() -> void:
	play_exit.visible = false


func _on_Play_mouse_entered() -> void:
	$Play.grab_focus()


func _on_Options_mouse_entered() -> void:
	$Options.grab_focus()


func _on_Exit_mouse_entered() -> void:
	$Exit.grab_focus()


func _on_Back_pressed() -> void:
	$BackgroundKeys.visible = false
	hide_back_button()
	show_buttons()


func _on_Back_mouse_entered() -> void:
	$Play.grab_focus()
	$SelectorBack/SelectorAnimaiton.play("idle")
