extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var animation_state
var characterAnimationTree
var direction := Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	characterAnimationTree=$AnimationTree
	animation_state = characterAnimationTree.get("parameters/playback")
	animation_state.start("Start")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

export var speed_=-100
export var velocity=0
var rotated=false
func rotate90():
	rotate_y(PI/2.0)


func _physics_process(delta):

	
	move_and_slide(get_global_transform().basis.z*velocity*delta,Vector3.UP)
	var anim=animation_state.get_current_node()
	
	
	print("- "+anim)
	match anim:
		"Start":
			if Input.is_action_just_pressed("jump"):
				animation_state.travel("Idle90")
			pass
		"Idle90":
			if Input.is_action_just_pressed("jump"):
				animation_state.travel("Idle180")
			pass
		"Idle180":
			if Input.is_action_just_pressed("jump"):
				animation_state.travel("Walk_loop")
			pass
		"Walk_loop":
			if Input.is_action_pressed("jump"):
				pass
			else:
				animation_state.travel("Idle180")
			pass
	


func _on_Player_move_beetle(position) -> void:
	if position == Vector3.ZERO:
		direction = Vector2.ZERO
	else:
		var direction3D = (position - global_transform.origin)
		direction = Vector2(direction3D.x, direction3D.z)

