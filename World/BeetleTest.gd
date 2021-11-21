extends KinematicBody


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
var center := Vector2.ZERO
var direction := Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	center = get_viewport().size/2
	print(global_transform.origin)

func move(final):
	if final == Vector3.ZERO:
		direction = Vector2.ZERO
	else:
		var direction3D = (final - global_transform.origin)
		direction = Vector2(direction3D.x, direction3D.z)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
