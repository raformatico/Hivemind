extends KinematicBody
class_name Player_old

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

enum states {IDLE, WALK, RUN, GLIDE, MIND, JUMP}
var snap
var direction = Vector3()
var velocity = Vector3()
var gravity_vector = Vector3()
var movement = Vector3()

signal in_mind
signal out_mind
signal move_beetle(position)

onready var acceleration := acceleration_floor
onready var speed := speed_default
onready var gravity := gravity_default
onready var body :=  $Body
onready var camera := $Camera
onready var glide_timer := $glide_timer
onready var glide_reset := $glide_reset

var center := Vector2.ZERO
var last_intersection = null
var characterAnimationTree
var state
var character_version="v0"
var animation_state
var hovering_=false

func _ready() -> void:
	center = get_viewport().size/2
	state = states.IDLE
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
	var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var direction_keys = Vector3(h_input, 0, f_input)
	# Get radians of camera rotation around Y axis
	var camera_rotation = camera.get_global_transformation().basis.get_euler().y
	# Rotate keys around Y by camera rotation
	direction = direction_keys.rotated(Vector3.UP, camera_rotation).normalized()
	
	match state:
		states.IDLE:
			pass
		states.GLIDE:
			pass
		states.RUN:
			pass
		states.MIND:
			body.rotation.y = camera_rotation
			direction = Vector3.ZERO
		states.JUMP:
			pass
		states.WALK:
			pass
		
	
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
	
	if Input.is_action_pressed("mind_connection") and state == states.MIND:
		var space_state = get_world().direct_space_state
		var rayOrigin = camera.camera.project_ray_origin(center)
		var rayEnd = rayOrigin + camera.camera.project_ray_normal(center) * 2000
		var intersection = space_state.intersect_ray(rayOrigin, rayEnd)
					
		if intersection.empty():
			if last_intersection != null:
					last_intersection.collider.move(Vector3.ZERO)
					last_intersection = null
		elif intersection.collider.is_in_group("Beetle"):
			last_intersection = intersection
			emit_signal("move_beetle",intersection.position)
		else:
			if last_intersection != null:
				emit_signal("move_beetle",Vector3.ZERO)
				last_intersection = null
	if Input.is_action_just_released("mind_connection"):
		if last_intersection != null:
			emit_signal("move_beetle",Vector3.ZERO)
			last_intersection = null
	
	if Input.is_action_just_pressed("mind_trick"):
		if state != states.MIND:
			state = states.MIND
			emit_signal("in_mind")
		else:
			state = states.IDLE
			if last_intersection != null:
				last_intersection.collider.move(Vector3.ZERO)
				last_intersection = null
			emit_signal("out_mind")

	if Input.is_action_pressed("glide") and not glide_timer.is_stopped():
		_on_glide()
		state = states.GLIDE
	
	if Input.is_action_just_released("glide"):
		if not glide_timer.is_stopped():
			glide_timer.stop()
			glide_reset.start()
			_out_of_glide()
			
	
	if Input.is_action_just_pressed("glide") and glide_reset.is_stopped():
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

func change_state(next_state) -> void:
	var previous_state = state
	
	enter_state(next_state)
	clean(previous_state)

func enter_state(next_state) -> void:
	state = next_state
	match next_state:
		states.GLIDE:
			acceleration = acceleration_glide
			speed = speed_glide
			gravity = gravity_glide
			snap = Vector3.DOWN
			hovering_=true
			animation_state.travel("Hover_loop")

func clean(previous_state) -> void:
	match previous_state:
		states.GLIDE:
			speed = speed_default
			gravity = gravity_default
			hovering_=false

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
	speed = speed_default
	gravity = gravity_default

	hovering_=false	
	#animation_state.travel("Moving_loop")
