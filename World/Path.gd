extends Path


var center := Vector2.ZERO
var last_point
onready var beetle := $PathFollow/Beetle
onready var path_follow := $PathFollow

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var last_point3D = curve.get_point_position(curve.get_point_count()-1)
	last_point = Vector2(last_point3D.x,last_point3D.z)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if beetle.direction != Vector2.ZERO:
		if beetle.direction.dot(last_point) > 0:
			path_follow.offset = lerp(path_follow.offset,path_follow.offset+5,0.10*delta)
		else:
			path_follow.offset = lerp(path_follow.offset,path_follow.offset-5,0.10*delta)
