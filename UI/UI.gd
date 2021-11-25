extends MarginContainer

onready var lymph : AnimatedSprite = $VBoxContainer/up_container/lymph
onready var stamina : TextureProgress = $VBoxContainer/bot_container/stamina
onready var tween : Tween = $stamina_tween
onready var tween_drain : Tween = $stamina_tween_drain
onready var tween_fade : Tween = $stamina_fade

var drain = true

func time_to_play() -> void:
	pass
	

func stop() -> void:
	pass


func start_fill() -> void:
	pass


func _ready() -> void:
	stamina.modulate = Color(1,1,1,0)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		if drain:
			drain = false
			_show_stamina()
		else:
			_hide_stamina()
			drain = true
			

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
