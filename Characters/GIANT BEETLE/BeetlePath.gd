extends Path


var center := Vector2.ZERO
var last_point
onready var beetle := $PathFollow/GIANT_BEETLE
onready var path_follow := $PathFollow

export var step=10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var last_point3D = to_global(curve.get_point_position(curve.get_point_count()-1))
	last_point = Vector2(last_point3D.x,last_point3D.z)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if beetle.direction != Vector2.ZERO:
		var beetle_positive_path = (last_point - Vector2(beetle.global_transform.origin.x,beetle.global_transform.origin.z)).normalized()
		if Global.DEBUG:
			var text_to_write = """Beetle position = {0}
			
			Global intersection position = {1}
			
			Relative Intersection = {2}
			
			Last point global position = {3}
			
			beetle_positive_path = {4}
			
			Dot product = {5}
			""".format({"0":beetle.position, 
						"1": beetle.intersection_position, 
						"2": beetle.direction,
						"3":last_point,
						"4":beetle_positive_path,
						"5":beetle.direction.dot(beetle_positive_path)
						})
			
			Global.emit_signal("debug_write",text_to_write)
		if beetle.direction.dot(beetle_positive_path) > 0:
			path_follow.offset = lerp(path_follow.offset,path_follow.offset+step,0.10*delta)
		else:
			path_follow.offset = lerp(path_follow.offset,path_follow.offset-step,0.10*delta)



