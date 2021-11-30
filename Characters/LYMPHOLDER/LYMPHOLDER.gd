extends KinematicBody

export var openNearPlayer : bool = false
onready var animationTree : AnimationTree = $AnimationTree

func _ready():
	$AnimationPlayer.play("idle")
	$AnimationPlayer.seek(randf()*$AnimationPlayer.current_animation_length)


func _on_PlayerDetector_body_entered(body: Node) -> void:
	if body is Player and openNearPlayer:
		print("OPEN")
