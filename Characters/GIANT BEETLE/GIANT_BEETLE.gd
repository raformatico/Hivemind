extends KinematicBody


var player_in_area : bool = false
var animation_state
var characterAnimationTree
var direction := Vector2.ZERO
var intersection_position := Vector2.ZERO
var position := Vector2.ZERO
export var speed_=-100
export var velocity=0
var rotated=false


# Called when the node enters the scene tree for the first time.
func _ready():
	characterAnimationTree=$AnimationTree
	animation_state = characterAnimationTree.get("parameters/playback")
	animation_state.start("Start")

func rotate90():
	rotate_y(PI/2.0)


func _physics_process(delta):
	move_and_slide(get_global_transform().basis.z*velocity*delta,Vector3.UP)
	var anim=animation_state.get_current_node()
	
	"""
	#print("- "+anim)
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
	"""


func _on_Player_move_beetle(position_local) -> void:
	if player_in_area:
		if position_local == Vector3.ZERO:
			direction = Vector2.ZERO
		else:
			position = Vector2(global_transform.origin.x, global_transform.origin.z)
			intersection_position = Vector2(position_local.x, position_local.z)
			var direction_intersection = (position_local - global_transform.origin)
			direction = Vector2(direction_intersection.x, direction_intersection.z).normalized()


func _on_puzzle_area_body_entered(body: Node) -> void:
	if body is Player:
		player_in_area = true


func _on_puzzle_area_body_exited(body: Node) -> void:
	if body is Player:
		player_in_area = false
