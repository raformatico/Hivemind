extends KinematicBody
class_name Player

export var acceleration_floor := 10
export var acceleration_air := 1
export var acceleration_glide := 3
export var angular_velocity := 30
export var gravity_default := 9.8
export var gravity_glide := 6
export var jump := 5
export var camera_acceleration := 40
export var mouse_sense := 0.1
export var joystick_sense := 1
export var up_limit := -55
export var low_limit := 14
export var speed_default := 7
export var speed_glide := 12
export var gliding_factor := 2

var snap
var direction = Vector3()
var velocity = Vector3()
var gravity_vector = Vector3()
var movement = Vector3()

onready var acceleration := acceleration_floor
onready var speed := speed_default
onready var gravity := gravity_default
onready var body :=  $Body
onready var camera := $Camera
onready var glide_timer := $glide_timer
onready var glide_reset := $glide_reset

var characterAnimationTree

var character_version="v0"
var animation_state
var hovering_=false

func _ready() -> void:
	#remove ifs when definitive character is ready.
	if get_node("PhilosopherBug") !=null:
		body=$PhilosopherBug 
		characterAnimationTree=$PhilosopherBug/RootNode/AnimationTree
	elif get_node("bugatti") !=null:
		body=$bugatti 	
		characterAnimationTree=$bugatti/AnimationTree
		character_version="v0"
	elif get_node("bugattiv1") !=null:
		body=$bugattiv1 	
		characterAnimationTree=$bugattiv1/AnimationTree
		animation_state = characterAnimationTree.get("parameters/playback")
		animation_state.start("Idle_loop")
		character_version="v1"
		
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
		if glide_timer.is_stopped():
			acceleration = acceleration_floor
		gravity_vector = Vector3.ZERO  # before was called gravity...
	else:
		"""var gliding_factor_=1
		if Input.is_action_pressed("jump"):
			gliding_factor_=gliding_factor
			print("glide")"""
		
		snap = Vector3.DOWN
		if glide_timer.is_stopped():
			acceleration = acceleration_air
		gravity_vector += Vector3.DOWN * gravity * delta
	
	if Input.is_action_pressed("glide") and not glide_timer.is_stopped():
		_on_glide()
	
	if Input.is_action_just_released("glide"):
		if not glide_timer.is_stopped():
			glide_timer.stop()
			glide_reset.start()
			_out_of_glide()
			
	
	if Input.is_action_just_pressed("glide") and glide_reset.is_stopped():
		print("Glide")
		glide_timer.start()
		_on_glide()
	
	if Input.is_action_just_pressed("jump") and is_on_floor() and glide_timer.is_stopped():
		snap = Vector3.ZERO
		gravity_vector = Vector3.UP * jump
		animation_state.travel("Jump")
	
	#make it move
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	# TODO use friction to stop the player from moving
	# if direction == Vector3.ZERO:
	# velocity = velocity.linear_interpolate(direction * speed, friction * delta)
	movement = velocity + gravity_vector
	
	move_and_slide_with_snap(movement, snap, Vector3.UP)

	var velocity_=velocity
	
	if character_version=="v0":
		# the speed triggers the blended animation
		characterAnimationTree["parameters/blend_position"].x=velocity_.length()
		characterAnimationTree["parameters/blend_position"].y=gravity_vector.length()
		#print(velocity.length()/speed,velocity_.length())
	elif character_version=="v1":
		var state_machine = characterAnimationTree["parameters/playback"]
		#print(velocity_.length())
		if not hovering_ and is_on_floor():
			if velocity_.length()>0:
				state_machine.travel("Moving_loop")
				characterAnimationTree.set("parameters/Moving_loop/blend_position",velocity_.length())	
				#print(state_machine.get_travel_path("Jump"))
				#characterAnimationTree["parameters/blend_position"].x=velocity_.length()
			else:
				# state_machine.travel("Idle-loop")
				#print("Loop")
				state_machine.travel("Idle_loop")
		
#func stop():
#	$PhilosopherBug/RootNode/AnimationPlayer.play("idle")
#	#$PhilosopherBug/RootNode/AnimationTree.
#
#func walk():
#	$PhilosopherBug/RootNode/AnimationPlayer.play("walk")


func _on_glide_timer_timeout() -> void:
	glide_reset.start()
	speed = speed_default

func _on_glide():
	acceleration = acceleration_glide
	speed = speed_glide
	gravity = gravity_glide
	snap = Vector3.DOWN
	
	hovering_=true
	animation_state.travel("Hover_loop")

func _out_of_glide():
	print("Glide_out")
	speed = speed_default
	gravity = gravity_default

	hovering_=false	
	#animation_state.travel("Moving_loop")
