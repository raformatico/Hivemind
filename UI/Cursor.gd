extends Control

const IN_PUZZLE = "connection_zone"
const HOLD_RMB = "hold_RMB"
const HOLD_R2 = "hold_R2"
const CONNECTED = "connected"

onready var cursor : AnimatedSprite = $CenterContainer/MarginContainer/cursor


var i = 0

func show_cursor() -> void:
	set_visible(true)


func hide_cursor() -> void:
	set_visible(false)


func _ready() -> void:
	hide_cursor()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		if i == -1:
			cursor.speed_scale = 1
			cursor.animation = IN_PUZZLE
		elif i == 0:
			cursor.speed_scale = 2
			cursor.animation = IN_PUZZLE
		elif i == 1:
			cursor.speed_scale = 1
			cursor.animation = HOLD_RMB
		elif i == 2:
			cursor.animation = HOLD_R2
		elif i == 3:
			cursor.animation = CONNECTED
			i = -2
		i += 1

func _on_Player_in_mind() -> void:
	show_cursor()

func _on_Player_out_mind() -> void:
	hide_cursor()


func _on_puzzle_area_body_entered(body: Node) -> void:
	if body is Player:
		cursor.animation = IN_PUZZLE
		show_cursor()


func _on_puzzle_area_body_exited(body: Node) -> void:
	if body is Player:
		hide_cursor()
