extends KinematicBody
class_name Player

export var acceleration_floor := 10
export var acceleration_air := 1
export var acceleration_glide := 3
export var angular_velocity := 30
export var gravity_default := 9.8
export var gravity_glide := 6
export var jump := 5
export var mouse_sense := 0.1
export var joystick_sense := 1
export var speed_default := 1
export var speed_thr_default := 0.1
export var speed_run := 4
export var speed_glide := 12
export var gliding_factor := 2

enum states {IDLE, WALK, RUN, GLIDE, MIND, JUMP}
var snap
var direction = Vector3()
var velocity = Vector3()
var gravity_vector = Vector3()
var movement = Vector3()
var lymph: int = 0 setget set_lymph, get_lymph

signal in_mind
signal out_mind
signal change_cursor(cursor_anim,speed)
signal move_puzzle(position)
signal lymph_changed(lymph_count)
signal glide_started(glide_time)
signal glide_restarted(reset_time)


export var glide_max_time : float = 10
export var reset_max_time : float = 3
onready var acceleration := acceleration_floor
onready var speed := speed_default
onready var speed_thr := speed_thr_default
onready var gravity := gravity_default
onready var body :=  $Body
onready var camera := $Camera
onready var glide_timer := $glide_timer
onready var glide_reset := $glide_reset


var puzzle_parent = null
var puzzle_transform : Transform = Transform(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO,Vector3.ZERO)
var center := Vector2.ZERO
var last_intersection = null
var characterAnimationTree
var state
var character_version="v0"
var animation_state
var hovering_=false

func get_lymph() -> int:
	return lymph


func set_lymph(new_lymph : int) -> void:
	lymph = new_lymph


func on_lymph_picked() -> void:
	lymph += 1
	emit_signal("lymph_changed", lymph)
	if lymph == 5:
		Global.lymph_completed = true
		if Global.player_in_area_final:
			get_tree().change_scene("res://Menu/ending.tscn")


var playback_speed=1
var animationPlayer=null

func _ready() -> void:
	glide_timer.wait_time = glide_max_time
	glide_reset.wait_time = reset_max_time
	Global.connect("lymph_picked", self, "on_lymph_picked")
	Global.connect("puzzle_entered",self,"on_puzzle_entered")
	Global.connect("puzzle_exited",self,"on_puzzle_exited")
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
		animationPlayer=$bugattiv1/AnimationPlayer
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
	
	if not puzzle_parent == null and not state == states.MIND:
		var angle = get_angle_to_puzzle(camera_rotation)
		var rotation_speed = range_lerp(angle, 3.14, 0, 1, 4)
		var space_state = get_world().direct_space_state
		var rayOrigin = camera.camera.project_ray_origin(center)
		var rayEnd = rayOrigin + camera.camera.project_ray_normal(center) * 200
		var intersection = space_state.intersect_ray(rayOrigin, rayEnd)
		if not intersection.empty() and intersection.collider == puzzle_parent:
			emit_signal("change_cursor","hold_RMB",1)
			if Input.is_action_just_pressed("mind_connection"):
				emit_signal("in_mind")
				emit_signal("change_cursor","connected",1)
				animation_state.travel("Connect_loop")
				state=states.MIND
		else:
			emit_signal("change_cursor","connection_zone",rotation_speed)
	
	if is_on_floor():
		snap = -get_floor_normal()
		if glide_timer.is_stopped():
			acceleration = acceleration_floor
		gravity_vector = Vector3.ZERO  

	var velocity_=velocity
	
	var state_machine = characterAnimationTree["parameters/playback"]
	match state:
		states.IDLE:
			if Input.is_action_just_pressed("glide") and glide_reset.is_stopped():
				glide_timer.start()
				state = states.GLIDE
				animation_state.travel("Hover_loop")
				_on_glide()
	
			elif Input.is_action_just_pressed("jump") and is_on_floor() and glide_timer.is_stopped():
				snap = Vector3.ZERO
				gravity_vector = Vector3.UP * jump
				state=states.JUMP
				animation_state.travel("Jump")							
			elif velocity_.length_squared() > speed_thr:
				state=states.WALK
				state_machine.travel("Walk_loop")
			else:
				state_machine.travel("Idle_loop")
				
		states.GLIDE:
			if Input.is_action_pressed("glide") and not glide_timer.is_stopped():
				_on_glide()
			elif Input.is_action_just_released("glide"):
				if not glide_timer.is_stopped():
					_restart_timer()
					_out_of_glide()
				state=states.WALK
			else:
				state=states.WALK

		states.RUN:
			speed = speed_run
			if Input.is_action_just_pressed("jump") and is_on_floor() and glide_timer.is_stopped():
				snap = Vector3.ZERO
				gravity_vector = Vector3.UP * jump
				state=states.JUMP
				animation_state.travel("Jump")
			elif Input.is_action_just_pressed("glide") and glide_reset.is_stopped():
				glide_timer.start()
				emit_signal("glide_started", glide_max_time)
				state = states.GLIDE
				animation_state.travel("Hover_loop")
				_on_glide()						
			elif Input.is_action_just_released("run"):
				state = states.IDLE
				state_machine.travel("Idle_loop")
			else:
				# var state_machine = characterAnimationTree["parameters/playback"]
				#print(velocity_.length())
				if glide_timer.is_stopped() and is_on_floor():
					if velocity_.length_squared() > speed_thr:
						state_machine.travel("Run_loop")
						
						### characterAnimationTree.set("parameters/Moving_loop/blend_position",velocity_.length())	
						
						#print(state_machine.get_travel_path("Jump"))
						#characterAnimationTree["parameters/blend_position"].x=velocity_.length()
					else:
						# state_machine.travel("Idle-loop")
						#print("Loop")
						## velocity = Vector3.ZERO
						state=states.IDLE
						### state_machine.travel("Idle_loop")
						state_machine.travel("Walk_loop") 
		states.MIND:
			body.rotation.y = camera_rotation
			direction = Vector3.ZERO
								
			if Input.is_action_pressed("mind_connection"): # and state == states.MIND:
				AudioEngine.play_sfx("concentracion")
				AudioEngine.eq_music()
				var space_state = get_world().direct_space_state
				var rayOrigin = camera.camera.project_ray_origin(center)
				var rayEnd = rayOrigin + camera.camera.project_ray_normal(center) * 2000
				var intersection = space_state.intersect_ray(rayOrigin, rayEnd)
				if intersection.empty():
					pass
					"""if last_intersection != null:
							last_intersection.collider.move(Vector3.ZERO)
							last_intersection = null"""
				elif intersection.collider.is_in_group("Puzzle"):
					last_intersection = intersection
					emit_signal("move_puzzle",intersection.position)
				else:
					if last_intersection != null:
						emit_signal("move_puzzle",Vector3.ZERO)
						last_intersection = null
			else:
				AudioEngine.stop_sfx()
				AudioEngine.uneq_music()
				emit_signal("move_puzzle",Vector3.ZERO)
				emit_signal("out_mind")
				state=states.IDLE
				animation_state.travel("Idle_loop")
			"""if Input.is_action_just_released("mind_connection"):
				if last_intersection != null:
					emit_signal("move_puzzle",Vector3.ZERO)
					last_intersection = null
			
			if Input.is_action_just_pressed("mind_trick"):	
				state = states.IDLE
				if last_intersection != null:
					last_intersection.collider.move(Vector3.ZERO)
					last_intersection = null
				emit_signal("out_mind")"""
			
		states.JUMP:
			speed = speed_default
			if is_on_floor():
				state=states.WALK
				# state_machine.travel("Mooving_loop")
			elif Input.is_action_just_pressed("glide") and glide_reset.is_stopped():
				glide_timer.start()
				emit_signal("glide_started", glide_max_time)
				state = states.GLIDE
				animation_state.travel("Hover_loop")
				_on_glide()						
		states.WALK:
			#AudioEngine.play_sfx("walk")
			speed = speed_default
			if Input.is_action_just_pressed("jump") and is_on_floor() and glide_timer.is_stopped():
				snap = Vector3.ZERO
				gravity_vector = Vector3.UP * jump
				state=states.JUMP
				animation_state.travel("Jump")	
			elif Input.is_action_just_pressed("glide") and glide_reset.is_stopped():
				emit_signal("glide_started", glide_max_time)
				glide_timer.start()
				state = states.GLIDE
				animation_state.travel("Hover_loop")
				_on_glide()
			elif Input.is_action_pressed("run"):
				state = states.RUN
				state_machine.travel("Run_loop") ###
			else:
				#print(velocity_.length())
				if glide_timer.is_stopped() and is_on_floor():
					if velocity_.length_squared() > speed_thr_default:
						if Input.is_action_pressed("run"):
							speed=speed_run
							state_machine.travel("Run_loop") ###
						else:
							speed=speed_default
							state_machine.travel("Walk_loop")
							
						### characterAnimationTree.set("parameters/Moving_loop/blend_position",velocity_.length())	
						
						#animationPlayer.playback_speed=2*velocity_.length()/speed_default
						#print(state_machine.get_travel_path("Jump"))
						#characterAnimationTree["parameters/blend_position"].x=velocity_.length()
					else:
						# state_machine.travel("Idle-loop")
						#print("Loop")
						AudioEngine.stop_sfx()
						state=states.IDLE
						state_machine.travel("Idle_loop")
					pass
		
		#jumping and gravity
	if is_on_floor():
		pass
	else:
		"""var gliding_factor_=1
		if Input.is_action_pressed("jump"):
			gliding_factor_=gliding_factor
			print("glide")"""
		
		snap = Vector3.DOWN
		if glide_timer.is_stopped():
			acceleration = acceleration_air
		gravity_vector += Vector3.DOWN * gravity * delta
	
	
	
	#make it move
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	
	# TODO use friction to stop the player from moving
	# if direction == Vector3.ZERO:
	# velocity = velocity.linear_interpolate(direction * speed, friction * delta)
	movement = velocity + gravity_vector
	
	move_and_slide_with_snap(movement, snap, Vector3.UP, false, 4, PI/4, false)
	

	
#	if character_version=="v0":
#		# the speed triggers the blended animation
#		characterAnimationTree["parameters/blend_position"].x=velocity_.length()
#		characterAnimationTree["parameters/blend_position"].y=gravity_vector.length()
#		#print(velocity.length()/speed,velocity_.length())
#	elif character_version=="v1":
#		var state_machine = characterAnimationTree["parameters/playback"]
#		#print(velocity_.length())
#		if not hovering_ and is_on_floor():
#			if velocity_.length()>0:
#				state_machine.travel("Moving_loop")
#				characterAnimationTree.set("parameters/Moving_loop/blend_position",velocity_.length())	
#				#print(state_machine.get_travel_path("Jump"))
#				#characterAnimationTree["parameters/blend_position"].x=velocity_.length()
#			else:
#				# state_machine.travel("Idle-loop")
#				#print("Loop")
#				state_machine.travel("Idle_loop")
		
#func stop():
#	$PhilosopherBug/RootNode/AnimationPlayer.play("idle")
#	#$PhilosopherBug/RootNode/AnimationTree.
#
#func walk():
#	$PhilosopherBug/RootNode/AnimationPlayer.play("walk")

#func change_state(next_state) -> void:
#	var previous_state = state
#
#	enter_state(next_state)
#	clean(previous_state)
#
#func enter_state(next_state) -> void:
#	state = next_state
#	match next_state:
#		states.GLIDE:
#			acceleration = acceleration_glide
#			speed = speed_glide
#			gravity = gravity_glide
#			snap = Vector3.DOWN
#			hovering_=true
#			animation_state.travel("Hover_loop")
#
#func clean(previous_state) -> void:
#	match previous_state:
#		states.GLIDE:
#			speed = speed_default
#			gravity = gravity_default
#			hovering_=false

func _on_glide_timer_timeout() -> void:
	glide_reset.start()
	speed = speed_default
	glide_reset.wait_time = reset_max_time
	glide_reset.start()
	emit_signal("glide_restarted", reset_max_time)

func _on_glide():
	acceleration = acceleration_glide
	speed = speed_glide
	gravity = gravity_glide
	snap = Vector3.DOWN
	hovering_=true
	animation_state.travel("Hover_loop")

func _restart_timer():
	var proportion_left : float = glide_timer.time_left/glide_max_time
	glide_timer.stop()
	var reset_time : float = reset_max_time * (1 - proportion_left)
	glide_reset.wait_time = reset_time
	glide_reset.start()
	emit_signal("glide_restarted", reset_time)

func _out_of_glide():
	speed = speed_default
	gravity = gravity_default

	hovering_=false	
	#animation_state.travel("Moving_loop")

func get_angle_to_puzzle(camera_rotation) -> float:
	var looking_at = Vector3(0,0,1).rotated(Vector3.UP,camera_rotation)
	var from_puzzle_to_me = global_transform.origin - puzzle_transform.origin
	return looking_at.angle_to(from_puzzle_to_me)


func on_puzzle_entered(puzzle_transform_new : Transform, parent) -> void:
	puzzle_transform = puzzle_transform_new
	puzzle_parent = parent
	
	
func on_puzzle_exited() -> void:
	puzzle_parent = null
	
func move_player_to_lake()-> void:
	transform = get_node("../RespawnLakepoint").global_transform
	camera.rotation_degrees = Vector3(0,-70,0)
	body.rotation.y = camera.get_global_transformation().basis.get_euler().y
	#get_node("../RespawnLakepoint").global_transform.basis.get_euler()
	#transform.origin = Vector3(88,0,-70)
	#transform.basis.rotated(Vector3(0,1,0),deg2rad(-85))#rotation_degrees(Vector3(0,-85,0))
	

func _on_fade_in_tween_all_completed() -> void:
	move_player_to_lake()


