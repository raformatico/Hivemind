extends Area

export var area_radius := 10

onready var collision : CollisionShape = $CollisionShape


func _ready() -> void:
	collision.shape.radius = area_radius


func _on_puzzle_area_body_entered(body: Node) -> void:
	if body is Player:
		print("Enter")
		Global.emit_signal("puzzle_entered",self.global_transform, get_parent())


func _on_puzzle_area_body_exited(body: Node) -> void:
	if body is Player:
		print("Exit")
		Global.emit_signal("puzzle_exited")
