extends StaticBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player_in_area=false
var singing=false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_puzzle_larvae_body_entered(body):
	if body is Player:
		player_in_area = true

func _on_puzzle_larvae_body_exited(body):
	if body is Player:
		player_in_area = false
		for player in AudioEngine.wormsinger:
			player.volume_db = AudioEngine.silence_volume
		singing=false
		
func start_singing():
	AudioEngine.start_worm_chorus()

func _on_Player_move_puzzle(position):
	if not singing:
		start_singing()
		singing=true
		
	if player_in_area:
		for player in AudioEngine.wormsinger:
			player.volume_db = 0
		AudioEngine.depitch_and_check(0, "x", 1, Vector2(100,100), get_viewport().get_mouse_position())
