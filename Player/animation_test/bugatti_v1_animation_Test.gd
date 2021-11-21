extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var state
var parameters
var speed=0

# Called when the node enters the scene tree for the first time.
func _ready():
	state = $AnimationTree.get("parameters/playback")
	parameters =  $AnimationTree.get("parameters/Moving_loop/blend_position")
	state.start("Idle_loop")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_key_pressed(KEY_UP):
		
		speed=speed+delta
		if speed > 12:
			speed=12
		
		state.travel("Moving_loop")
		
		if Input.is_key_pressed(KEY_SHIFT):
			$AnimationTree.set("parameters/Moving_loop/blend_position",speed)
		else:
			$AnimationTree.set("parameters/Moving_loop/blend_position",speed)
	elif Input.is_key_pressed(KEY_SPACE):
		state.travel("Jump")
	elif Input.is_key_pressed(KEY_CONTROL):
		state.travel("Hover_loop")
	elif Input.is_key_pressed(KEY_E):
		state.travel("Connect_loop")
	elif Input.is_key_pressed(KEY_DOWN):
		speed=speed-delta
		if speed<=0:
			speed=0
		state.travel("Idle_loop")
