extends Control

onready var lymph : AnimatedSprite = $MarginContainer/VBoxContainer/up_container/lymph
onready var stamina : TextureProgress = $MarginContainer/VBoxContainer/bot_container/stamina
onready var tween : Tween = $stamina_tween
onready var tween_drain : Tween = $stamina_tween_drain
onready var tween_fade : Tween = $stamina_fade
onready var fade_color : ColorRect = $fade_color
onready var fade_in : Tween = $fade_color/fade_in
onready var fade_out : Tween = $fade_color/fade_out

var drain = true

func time_to_play() -> void:
	pass
	

func stop() -> void:
	pass


func start_fill() -> void:
	pass



func _ready() -> void:
	stamina.modulate = Color(1,1,1,0)
	fade_color.color = Color(0,0,0,0)


func change_lymph(lymph_count : int) -> void:
	lymph.frame = lymph_count


func _on_Player_lymph_changed(lymph_count) -> void:
	change_lymph(lymph_count)


func _show_stamina() -> void:
	tween_fade.interpolate_property(stamina,"modulate",Color(1,1,1,0),Color(1,1,1,1),0.3,Tween.TRANS_CUBIC)
	tween_fade.start()


func _hide_stamina() -> void:
	tween_fade.interpolate_property(stamina,"modulate",Color(1,1,1,1),Color(1,1,1,0),0.3,Tween.TRANS_CUBIC)
	tween_fade.start()

func _on_Player_glide_started(glide_time) -> void:
	_show_stamina()
	tween.interpolate_property(stamina, "value", 100, 0, glide_time,Tween.TRANS_LINEAR)
	tween.start()


func _on_Player_glide_restarted(reset_time) -> void:
	if not stamina.modulate == Color(1,1,1,1):
		_show_stamina()
	if tween.is_active():
		tween.stop_all()
	tween_drain.interpolate_property(stamina, "value", stamina.value, 100, reset_time,Tween.TRANS_LINEAR)
	tween_drain.start()


func _on_stamina_tween_drain_tween_completed(object: Object, key: NodePath) -> void:
	if stamina.value == 100:
		_hide_stamina()




func _on_PlayerOnLakeDetector_body_entered(body: Node) -> void:
	if body is Player:
		fade_color.visible = true
		fade_in.interpolate_property(fade_color,"color",Color(0,0,0,0),Color(0,0,0,1),0.2,Tween.TRANS_CUBIC)
		fade_in.start()


func _on_fade_in_tween_all_completed() -> void:
	fade_out.interpolate_property(fade_color,"color",Color(0,0,0,1),Color(0,0,0,0),1.0,Tween.TRANS_CUBIC)
	fade_out.start()


func _on_fade_out_tween_completed(object: Object, key: NodePath) -> void:
	fade_color.visible = false
