extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var in_song="larvas"
export var out_song="paisaje"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_LarvaeZone_body_entered(body):
	AudioEngine.crossfade_to_song(in_song, 3)


func _on_LarvaeZone_body_exited(body):
	AudioEngine.crossfade_to_song(out_song, 3)
