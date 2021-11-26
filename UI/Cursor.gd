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


func _on_puzzle_area_body_entered(body: Node) -> void:
	if body is Player:
		cursor.animation = IN_PUZZLE
		show_cursor()


func _on_puzzle_area_body_exited(body: Node) -> void:
	if body is Player:
		hide_cursor()


func _on_Player_change_cursor(cursor_anim, speed) -> void:
	if not cursor_anim == "":
		cursor.animation = cursor_anim
	cursor.speed_scale = speed
