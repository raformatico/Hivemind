extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var in_mind=false

func _on_TouchingWorms_body_entered(body):
	if body.is_in_group("ChordWorm"):
		if in_mind:
			body._getting_out()
		#print("Getting out")


func _on_TouchingWorms_body_exited(body):
	if body.is_in_group("ChordWorm"):
		body._getting_in()
		#print("Getting in")


func _on_Player_in_mind():
	in_mind=true


func _on_Player_out_mind():
	in_mind=false
