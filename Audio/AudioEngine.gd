extends Node

var audio_dict = {}

#List of our songs and path to them
const songs = ["paisaje", "laguna", "escarabajo", "larvas", "wind"]
const sfxs = ["concentracion", "victory", "walk", "run", "buzz"]
const sfx_loop_data = {"concentracion":1.715, "victory":0.0, "walk":0.253, "run":0.284, "buzz":0.265}
const music_path = "res://Audio/music/"
const sfx_path = "res://Audio/sfx/"

#Shortcut for one of our players
const PL_1 = 0
const PL_2 = 1

#-70dB cannot be heard by any means
var silence_volume = -70

#This will contain all our OGG & WAV files
var songlist = {}
var sfxlist = {}

#List of AudioPlayers
var music = [AudioStreamPlayer.new(), AudioStreamPlayer.new()]
var wormsinger = [AudioStreamPlayer.new(), AudioStreamPlayer.new(), AudioStreamPlayer.new()]
var sfx = AudioStreamPlayer.new()
var wind = AudioStreamPlayer.new()

#Current song and player
var cur_player = PL_1
var cur_song = "paisaje" #TODO: set menu song

#Time to control fade or crossfade
var time_fades = -1.0

#Controls crossfading, which takes place whenever time_cross >= 0.0
var cross_speed = 0.0
var crossfading = false

#Controls fade_out
var fade_speed = 0.0
var fadingout = false

#Controls music eqing
var rate = 0.1
var eqing = false

func _ready():
	
	#Pause does not affect the audio
	pause_mode = Node.PAUSE_MODE_PROCESS
	
	#Set both to go on same audio bus
	music[PL_1].bus = "music"
	music[PL_2].bus = "music"
	sfx.bus = "sfx"
	wind.bus = "sfx"
	
	#Add nodes to the tree
	add_child(music[PL_1])
	add_child(music[PL_2])
	add_child(sfx)
	add_child(wind)
	
	#Load all songs in memory!
	var path_to_piece = music_path + "{song}.ogg" 
	for song in songs:
		songlist[song] = (load(path_to_piece.format({"song":song}))) 
	
	#Laod all SFX in memory!
	path_to_piece = sfx_path + "{sfx}.wav" 
	for effect in sfxs:
		sfxlist[effect] = (load(path_to_piece.format({"sfx":effect})))
		sfxlist[effect].set_loop_begin(44100*sfx_loop_data[effect])
	
	#Set up little worm sings
	var j = 1
	for auplayer in wormsinger:
		auplayer.bus = "worms" + str(j)
		auplayer.volume_db = silence_volume
		auplayer.stream = load(sfx_path + "larvas_gusano{j}.ogg".format({"j":j}))
		add_child(auplayer)
		j += 1
	
	#Time to start playing a song
	play_song(cur_song)
	
	#Wind effect is played perpetually...
	wind.stream = songlist["wind"]
	wind.volume_db = -1.0
	wind.play()
	set_process(false)


# --- Auxiliary and getters ---

func is_music_playing():
	return music[PL_1].playing or music[PL_2].playing

func get_music_volume():
	return music[PL_1].volume_db + music[PL_2].volume_db

# -- Main functions for playback ---

#Play a song, ignoring anything else. It starts from AudioPlayer 1.
func play_song(song:String):
	cur_player = PL_1
	
	music[PL_2].volume_db = silence_volume
	music[PL_2].stop()
	music[PL_1].stream = songlist[song]
	music[PL_1].volume_db = 0.0
	music[PL_1].play()

#Play a new SFX effect
func play_sfx(sfxname:String):
	if not sfx.playing:
		sfx.stream = sfxlist[sfxname]
		sfx.play()

func stop_sfx():
	sfx.stop()

func eq_music():
	var busindex = AudioServer.get_bus_index("mixmusic")
	AudioServer.set_bus_effect_enabled(busindex, 0, true)
	
	time_fades = 0.0
	eqing = true
	set_process(true)

func uneq_music():
	var busindex = AudioServer.get_bus_index("mixmusic")
	AudioServer.set_bus_effect_enabled(busindex, 0, false)
	eqing = false
	time_fades = -1.0
	set_process(false)

#Start a fade out with approximated duration fade_time
func fade_out(fade_time:float):
	cross_speed = abs(silence_volume) / fade_time
	fadingout = true
	time_fades = 0.0

#Start a crossfade to new song, with duration fade_time
func crossfade_to_song(new_song:String, fade_time:float):
	
	var the_other_player = int(not cur_player)
	
	#Play the new one from silence
	music[the_other_player].stream = songlist[new_song]
	music[the_other_player].volume_db = silence_volume
	music[the_other_player].play()
	
	#To ensure approximate synchro with music. Recall volume is set at silence
	if new_song=="larvas":
		start_worm_chorus()
	
	#Start crossfading
	cross_speed = abs(silence_volume) / fade_time
	crossfading = true
	time_fades = 0.0
	set_process(true)

#Make those worms start singing!
func start_worm_chorus():
	for j in range(3):
		wormsinger[j].play()

#Depitch one of the little worms depending on mouse position. Returns true if puzzle was solved for this one
#Axis: where to depitch worm. "x" or "y" is sensitive only to X or Y axis, "xy" is for both 
func depitch_and_check(index:int, axis:String, gain:float, solution:Vector2, mouse_pos:Vector2):
	
	var dist2_to_goal
	
	if axis=="x":
		dist2_to_goal = (solution.x - mouse_pos.x) / get_viewport().get_visible_rect().size.x
		dist2_to_goal *= dist2_to_goal
	elif axis=="y":
		dist2_to_goal = (solution.y - mouse_pos.y) / get_viewport().get_visible_rect().size.y
		dist2_to_goal *= dist2_to_goal
		dist2_to_goal /= get_viewport().get_visible_rect().size.y
	else:
		dist2_to_goal = solution.distance_squared_to(mouse_pos)
		dist2_to_goal /= get_viewport().get_visible_rect().size.x * get_viewport().get_visible_rect().size.y
	
	#Maximum depitch of factor 2.0, using a standard sigmoidal
	var busindex = AudioServer.get_bus_index("worms"+str(index+1))
	var effect = AudioServer.get_bus_effect(busindex, 0)
	effect.pitch_scale = 1.0 + tanh(gain*dist2_to_goal)
	
	return dist2_to_goal < 10.0


#--- Internal ----

#This function does update the crossfade on the process function
func do_crossfade(delta:float, fade_speed:float):
	
	var the_other_player = int(not cur_player)
	
	music[cur_player].volume_db -= delta * cross_speed * time_fades
	music[the_other_player].volume_db += delta * cross_speed  * time_fades
	
	time_fades += delta
	
	#Once volumes are OK, freeze them, finish current
	if music[the_other_player].volume_db > -0.1:
		music[the_other_player].volume_db = 0.0
		music[cur_player].volume_db = silence_volume
		cur_player = the_other_player
		crossfading = false
		set_process(false)


	
	set_process(true)

#Main loop for song fade out 
func do_fadeout(delta:float):
	
	music[PL_1].volume_db -= delta * cross_speed * time_fades
	music[PL_2].volume_db -= delta * cross_speed * time_fades
	
	time_fades += delta
	
	#Stop music reproduction when total volume is low enough
	if get_music_volume() <= 2*silence_volume:
		music[PL_1].stop()
		music[PL_2].stop()
		fadingout = false
		set_process(false)

func do_eq(delta):
	var busindex = AudioServer.get_bus_index("mixmusic")
	var filter = AudioServer.get_bus_effect(busindex, 0)
	
	filter.cutoff_hz = 1000.0 + 200.0*sin(rate*time_fades)
	
	time_fades += delta


#Do cross fade or fade out of the audio
func _process(delta):
	
	if crossfading:
		do_crossfade(delta, cross_speed)
	elif fadingout:
		do_fadeout(delta)
	elif eqing:
		do_eq(delta)
	
