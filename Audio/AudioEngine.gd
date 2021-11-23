extends Node

var audio_dict = {}

#const songs = ["background", "laguna"]
#const n_pieces = {"background": 26, "laguna": 25, "to_laguna":3}
const songs = ["laguna"]
const n_pieces = {"laguna": 25}
const audio_path = "res://Audio/music/"

const BUS_1 = 0
const BUS_2 = 1
var current = {"bus":BUS_1, "song": "laguna", "piece":0}

var next_music = [null, null]
var music = null

var time_counter = 0.0
var time_change = 0.0
var time_delay

var started = false


func _ready():
	
	#Preparar ambos players
	music = [AudioStreamPlayer.new(), AudioStreamPlayer.new()]
	
	music[BUS_1].bus = "music_1"
	music[BUS_2].bus = "music_2"
	
	music[BUS_1].volume_db = 0.0
	music[BUS_2].volume_db = -72.0
	
	add_child(music[BUS_1])
	add_child(music[BUS_2])
	
	#Cargar todas las canciones (de momento solo laguna, por pruebas es la mas facil)
	var path_to_piece = audio_path + "{song}/{song}-{index}.ogg" 
	var path_to_transitions = audio_path + "transitions/to_{song}-{index}.ogg"
	for song in songs:
		load_song_by_pieces(song, path_to_piece)
		
		#if song != "background":
		#	load_song_by_pieces("to_"+song, path_to_transitions)
	
	set_process(true)


#Comienza la musica en el BUS_1 y prepara el BUS_2
func start_music():
	music[BUS_1].stream = audio_dict["laguna0"]
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	time_change = audio_dict["laguna0"].get_length() - 1.0 + time_delay
	music[BUS_1].play()
	set_next_music_piece(BUS_2, "laguna", 1)


func load_song_by_pieces(song:String, path_to_look:String):
	for j in range(n_pieces[song]):
		var piecefile = path_to_look.format({"song":song, "index":"%0*d"%[3,j]})
		audio_dict[song + str(j)] = load(piecefile)

#Cambia la cancion en el BUS escogido
func set_next_music_piece(music_bus :int, next_song, next_part):
	music[music_bus].stop()
	music[music_bus].stream = audio_dict[next_song + str(next_part)]
	time_delay = AudioServer.get_time_to_next_mix() + AudioServer.get_output_latency()
	music[music_bus].play()

#Hace el switch entre buses
func change_bus_and_queue_next():
	print("TIMER")
	
	#MAL: NO SE REPRODUCE LA COLA DE REVERB SI CERRAMOS EL VOLUMEN AHORA, DEBERIA QUEDAR 1 SEGUNDO
	#CREO QUE NO HAY FORMA DE HACERLO REPRODUCIENDO AMBOS AUDIOS A LA VEZ
	#PERO ENTONCES NO HAY FORMA DE SINCRONIZAR LOS PRINCIPIOS
	music[current["bus"]].volume_db = -72 
	
	#intercambiar bus y desmutear
	current["bus"] = int(!current["bus"])
	music[current["bus"]].volume_db = 0.0
	
	#Tiempo para el siguiente cambio
	time_change = music[current["bus"]].stream.get_length()-1.0+time_delay
	
	#Preparar la siguiente pieza
	var next_piece = (current["piece"] + 1) % n_pieces[current["song"]]
	var the_other_bus = !current["bus"]
	set_next_music_piece(the_other_bus, current["song"], next_piece)
	current["piece"] = next_piece
	

#Todavia sin usar, eventos cambian la siguiente cancion
func buffer_song_change(new_song:String):
	var the_other_bus = int(!current["bus"])
	current["song"] = new_song
	current["piece"] = 0
	set_next_music_piece(the_other_bus, new_song, 0)

#Mas exacto que un timer
func _process(delta):
	if not started:
		started = true
		start_music()
	else:
		time_counter += delta
		if time_counter >= time_change:
			change_bus_and_queue_next()
			time_counter = 0.0
