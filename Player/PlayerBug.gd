extends KinematicBody
class_name Player

export var acceleration_floor = 10
export var acceleration_air = 1
export var angular_velocity = 30
export var gravity = 9.8
export var jump = 3
export var camera_acceleration = 40
export var mouse_sense = 0.1
export var joystick_sense = 1
export var up_limit := -55
export var low_limit := 14
export var speed = 7
export var gliding_factor=2

var snap
var direction = Vector3()
var velocity = Vector3()
var gravity_vector = Vector3()
var movement = Vector3()

var acceleration = acceleration_floor
onready var body :=  $Body
onready var camera := $Camera

var characterAnimationTree

func _ready() -> void:
	if get_node("PhilosopherBug") !=null:
		body=$PhilosopherBug 
		characterAnimationTree=$PhilosopherBug/RootNode/AnimationTree
	elif get_node("bugatti") !=null:
		body=$bugatti 	
		characterAnimationTree=$bugatti/AnimationTree
		
	body.set_as_toplevel(true)


func _process(delta: float) -> void:
	# Translate body to follow KinematicBody
	body.global_transform.origin = global_transform.origin
	# Rotate body to point to the movement
	if direction != Vector3.ZERO:
		body.rotation.y = lerp_angle(body.rotation.y, atan2(-direction.x, -direction.z), angular_velocity * delta)

func _physics_process(delta: float) -> void:
	# gravity = Vector3.DOWN # undefined?
	
	#get keyboard input
	direction = Vector3.ZERO
	#TODO review move_right and left
	var h_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var direction_keys = Vector3(h_input, 0, f_input)
	# Get radians of camera rotation around Y axis
	var camera_rotation = camera.get_global_transformation().basis.get_euler().y
	# Rotate keys around Y by camera rotation
	direction = direction_keys.rotated(Vector3.UP, camera_rotation).normalized()
	
	#jumping and gravity
	if is_on_floor():
		snap = -get_floor_normal()
		acceleration = acceleration_floor
		gravity_vector = Vector3.ZERO  # before was called gravity...
	else:
		var gliding_factor_=1
		if Input.is_action_pressed("jump"):
			gliding_factor_=gliding_factor
			print("glide")
		
		snap = Vector3.DOWN
		acceleration = acceleration_air
		gravity_vector += Vector3.DOWN * (gravity/gliding_factor_) * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		snap = Vector3.ZERO
		gravity_vector = Vector3.UP * jump
	
	#make it move
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	movement = velocity + gravity_vector
	
	move_and_slide_with_snap(movement, snap, Vector3.UP)

	var velocity_=velocity
	
	# the speed triggers the blended animation
	characterAnimationTree["parameters/blend_position"].x=velocity_.length()
	characterAnimationTree["parameters/blend_position"].y=gravity_vector.length()
	#print(velocity.length()/speed,velocity_.length())
	
#func stop():
#	$PhilosopherBug/RootNode/AnimationPlayer.play("idle")
#	#$PhilosopherBug/RootNode/AnimationTree.
#
#func walk():
#	$PhilosopherBug/RootNode/AnimationPlayer.play("walk")
