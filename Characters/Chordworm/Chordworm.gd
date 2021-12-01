extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var getting_out_ : bool =false
var getting_in_ : bool =false
export var offset=0.6

var origin
# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Singing·loop")
	$AnimationPlayer.seek(randf()*$AnimationPlayer.current_animation_length)
	origin=self.transform.origin.z

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _getting_out():
	if getting_out_==false:
		var tween=$Tween
	
		tween.interpolate_property(self, "translation:z", 
			self.transform.origin.z, origin+offset, 2, 
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		getting_out_=true
		getting_in_=false

func _getting_in():
	if getting_in_==false:
		var tween=$Tween
	
		tween.interpolate_property(self, "translation:z", 
			self.transform.origin.z, origin, 3, 
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.start()
		getting_in_=true
		getting_out_=false
