extends Spatial

export (NodePath) var target

export (float, 0.0, 2.0) var rotation_speed = PI/2

# nodes

onready var camera_in := $CameraIn
onready var camera := $CameraIn/Camera

# camera properties

export var up_limit := -55
export var low_limit := 20

# mouse properties

export (float, 0.001, 0.1) var mouse_sensitivity = 0.003
export (bool) var invert_y = false
export (bool) var invert_x = false

export var joystick_sensitivity = 1

var direction

func get_global_transformation() -> Vector3:
	return camera.global_transform

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
	camera_in.rotation.x = clamp(camera_in.rotation.x, deg2rad(up_limit), deg2rad(low_limit))
	#get joystick
	rotate_y(deg2rad((Input.get_action_strength("rotate_left") - Input.get_action_strength("rotate_right")) * joystick_sensitivity))
	camera_in.rotate_x(direction * deg2rad((Input.get_action_strength("rotate_up") - Input.get_action_strength("rotate_down")) * joystick_sensitivity))
	camera_in.rotation.x = clamp(camera_in.rotation.x, deg2rad(up_limit), deg2rad(low_limit))
	#if target:
		#global_transform.origin = get_node(target).global_transform.origin
