extends Spatial

export (NodePath) var target

export (float, 0.0, 2.0) var rotation_speed = PI/2

# nodes

onready var camera_in := $CameraIn
onready var camera := $CameraIn/Camera

# camera properties

export var up_limit := -55
export var low_limit := 20
export var fov_velocity := 10
export var translation_velocity := 10
export var near_fov := 30
export var near_translation := Vector3(0.5,-0.35,3)
# mouse properties

export (float, 0.001, 0.1) var mouse_sensitivity = 0.003
export (bool) var invert_y = false
export (bool) var invert_x = false

export var joystick_sensitivity = 1

var default_fov
var default_translation
var direction = 1   # Undefined value triggers error
var target_fov
var target_translation
var center := Vector2.ZERO
var last_intersection = null

func get_global_transformation() -> Vector3:
	return camera.global_transform

func _ready() -> void:
	center = get_viewport().size/2
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	default_fov = camera.fov
	default_translation = camera.translation
	target_fov = default_fov
	target_translation = default_translation
	# Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event):
	direction = 1 if invert_y else -1
	if event is InputEventMouseMotion:
		if event.relative.x != 0:
			rotate_object_local(Vector3.UP, direction * event.relative.x * mouse_sensitivity)
		if event.relative.y != 0:
			#var y_rotation = clamp(event.relative.y, -30, 30)
			#camera_in.rotate_object_local(Vector3.RIGHT, dir * y_rotation * mouse_sensitivity)
			camera_in.rotate_object_local(Vector3.RIGHT, direction * event.relative.y * mouse_sensitivity)

func _process(delta):
	if Input.is_action_pressed("mind_trick"):
		var space_state = get_world().direct_space_state
		var rayOrigin = camera.project_ray_origin(center)
		var rayEnd = rayOrigin + camera.project_ray_normal(center) * 2000
		var intersection = space_state.intersect_ray(rayOrigin, rayEnd)
		
		if not intersection.empty():
			if intersection.collider.is_in_group("Beetle"):
				last_intersection = intersection
				intersection.collider.move(intersection.position)
	
	if Input.is_action_just_released("mind_trick"):
		target_fov = default_fov
		target_translation = default_translation
		if last_intersection != null:
			last_intersection.collider.move(Vector3.ZERO)
			last_intersection = null
	
	if Input.is_action_just_pressed("mind_trick"):
		target_fov = near_fov
		target_translation = near_translation
	
	camera_in.rotation.x = clamp(camera_in.rotation.x, deg2rad(up_limit), deg2rad(low_limit))
	#get joystick
	rotate_y(deg2rad((Input.get_action_strength("rotate_left") - Input.get_action_strength("rotate_right")) * joystick_sensitivity))
	camera_in.rotate_x(direction * deg2rad((Input.get_action_strength("rotate_up") - Input.get_action_strength("rotate_down")) * joystick_sensitivity))
	camera_in.rotation.x = clamp(camera_in.rotation.x, deg2rad(up_limit), deg2rad(low_limit))
	
	if camera.fov != target_fov or camera.translation != target_translation:
		camera.fov = lerp(camera.fov,target_fov, fov_velocity * delta)
		camera.translation = lerp(camera.translation, target_translation, translation_velocity * delta)
	#if target:
		#global_transform.origin = get_node(target).global_transform.origin
