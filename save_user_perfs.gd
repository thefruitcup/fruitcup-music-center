extends Node

const CONFIG_PATH :String= "user://config.cfg"

const MAIN_WINDOW_STRING :String= "window_prefs"
const MAIN_MUSIC_STRING :String= "music_prefs"
var config : ConfigFile = ConfigFile.new()

var first_time : bool = true

func _exit_tree() -> void:
	save_config()

func save_config() -> void:
	config.set_value(MAIN_WINDOW_STRING, "pos", get_window().position)
	config.set_value(MAIN_WINDOW_STRING, "size", get_window().size)
	config.set_value(MAIN_WINDOW_STRING, "mode", get_window().mode)
	
	if get_window().mode == Window.Mode.MODE_WINDOWED:
		config.set_value(MAIN_WINDOW_STRING, "screen", get_window().current_screen)
	
	#the music paths are useless to save, they're most likely gonna be changed between sessions,
	#the directory is the most important to save
	config.set_value(MAIN_MUSIC_STRING, "dirs", Global.dirs_music_loaded.keys())
	config.set_value(MAIN_MUSIC_STRING,"song_playing",Global.current_track_path)
	config.set_value(MAIN_MUSIC_STRING,"song_position", Global.audio.get_playback_position())
	config.set_value(MAIN_MUSIC_STRING,"volume", AudioServer.get_bus_volume_db(0))
	
	config.save(CONFIG_PATH)

func load_config() -> void:
	var err : Error = config.load(CONFIG_PATH)
	
	if err != OK:
		Console.print_multiple("Couldn't load User's Save File! Error Code: ", err, " Path: ", CONFIG_PATH)
		return
	
	get_window().position = config.get_value(MAIN_WINDOW_STRING, "pos", get_window().position)
	get_window().mode = config.get_value(MAIN_WINDOW_STRING, "mode", get_window().mode)
	
	if get_window().mode == Window.Mode.MODE_WINDOWED:
		get_window().size = config.get_value(MAIN_WINDOW_STRING, "size", get_window().size)
	
	get_window().current_screen = config.get_value(MAIN_WINDOW_STRING, "screen", get_window().current_screen)
	
	for dir : String in config.get_value(MAIN_MUSIC_STRING, "dirs", []):
		Global.add_directory(dir,DirAccess.get_files_at(dir))
	
	AudioServer.set_bus_volume_db(0,config.get_value(MAIN_MUSIC_STRING,"volume",0))
	
	Global.on_audio_file_clicked(config.get_value(MAIN_MUSIC_STRING,"song_playing",""))
	Global.audio.seek(config.get_value(MAIN_MUSIC_STRING,"song_position",0))
	Global.audio.stream_paused = true
	first_time = false
