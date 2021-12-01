extends KinematicBody

var player_on_area : bool = false
var speed_default : float = 3
var speed : float = 3
var direction : Vector3 = Vector3.ZERO
var general_direction : Vector3 = Vector3.ZERO
var specific_direction : Vector3 = Vector3.ZERO
var velocity : Vector3 = Vector3.ZERO
export var acceleration : float = 5
export var specific_direction_multiplier : float = 3
export var general_direction_multiplier : float = 1
export var change_speed : float = 1
export var change_general : float = 4
export var change_specific : float = 1

onready var change_speed_timer : Timer = $change_speed
onready var change_specific_timer : Timer = $change_specific_direction
onready var change_general_timer : Timer = $change_general_direction

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if player_on_area:
		#Get Direction
		direction = (general_direction_multiplier * general_direction + specific_direction_multiplier * specific_direction).normalized()
		look_at(global_transform.origin + direction,Vector3.UP)
		velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
		move_and_slide_with_snap(velocity, -get_floor_normal(), Vector3.UP, false, 4, PI/4, false)
	#else:
	#	$AnimationPlayer.play("Magmaroach")


func _on_change_speed_timeout() -> void:
	if player_on_area:
		speed = speed_default * rand_range(0.5,1.5)
		change_speed_timer.wait_time = change_speed * rand_range(0.5,1.5)
		change_speed_timer.start()


func _on_change_general_direction_timeout() -> void:
	if player_on_area:
		general_direction = Vector3(rand_range(-1,1),0,rand_range(-1,1)).normalized()
		change_general_timer.wait_time = change_general * rand_range(0.5,1.5)
		change_general_timer.start()


func _on_change_specific_direction_timeout() -> void:
	if player_on_area:
		specific_direction = Vector3(rand_range(-1,1),0,rand_range(-1,1)).normalized()
		change_specific_timer.wait_time = change_specific * rand_range(0.5,1.5)
		change_specific_timer.start()


func _on_Player_Detector_body_entered(body: Node) -> void:
	if body is Player:
		$AnimationPlayer.play("Walk·loop")
		player_on_area = true
		if change_speed_timer.is_stopped() and change_general_timer.is_stopped() and change_specific_timer.is_stopped():
			change_speed_timer.wait_time = change_speed * rand_range(0.5,1.5)
			change_speed_timer.start()
			change_specific_timer.wait_time = change_specific * rand_range(0.5,1.5)
			change_specific_timer.start()
			change_general_timer.wait_time = change_general * rand_range(0.5,1.5)
			change_general_timer.start()


func _on_Player_Detector_body_exited(body: Node) -> void:
	if body is Player:
		player_on_area = false
		$AnimationPlayer.play("Magmaroach")
