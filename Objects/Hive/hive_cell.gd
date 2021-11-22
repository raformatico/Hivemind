extends StaticBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Cell_mouse_entered():
	#if $AnimationPlayer.current_animation!="coming":
	#	$AnimationPlayer.play("coming")
	if get_node("Chordworm")!=null:
		$Chordworm/AnimationPlayer.playback_speed=5
	


func _on_Cell_mouse_exited():
	#$AnimationPlayer.queue("going")
	#$AnimationPlayer.queue("idle")
	if get_node("Chordworm")!=null:
		$Chordworm/AnimationPlayer.playback_speed=0.5
	
