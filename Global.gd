extends Node

signal updated_directories
signal updated_metadata(data : MetadataResource, default_title : String)
const SUPPORTED_FORMATS :Array[String]= ["ogg","wav","mp3"]
const PATH_META_STRING :String= "PATH"

var dirs_music_loaded :Dictionary[String,PackedStringArray]={}
var all_music_files_loaded :PackedStringArray
var audio : AudioStreamPlayer

var current_track_path : String
var shuffle_queue :PackedStringArray
var is_shuffle_enabled : bool = false

func _ready() -> void:
	audio = AudioStreamPlayer.new()
	audio.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	
	add_child(audio)
	
	Console.enable_on_release_build = false
	Console.add_command("play_audio",on_audio_file_clicked,["file"],1)
	Console.add_command("reload",get_tree().reload_current_scene)
	UserPrefs.load_config()


func add_directory(dir_selected : String, files_in_dir : PackedStringArray) -> void:
	if dir_selected in dirs_music_loaded.keys():
		remove_dir(dir_selected)
	
	var music_files : PackedStringArray
	
	for file : String in files_in_dir:
		if file.get_extension() not in SUPPORTED_FORMATS: continue
		music_files.append(dir_selected + "/" + file)
	
	dirs_music_loaded[dir_selected] = music_files
	update_all_music_files_loaded()
	updated_directories.emit()

func remove_dir(dir_selected : String) -> void:
	if !dir_selected in dirs_music_loaded.keys(): return
	
	dirs_music_loaded.erase(dir_selected)
	update_all_music_files_loaded()
	updated_directories.emit()

func update_all_music_files_loaded() -> void:
	all_music_files_loaded.clear()
	
	for key : String in dirs_music_loaded:
		all_music_files_loaded.append_array(dirs_music_loaded[key])
	
	all_music_files_loaded.sort()

func get_metadata(file :String= current_track_path) -> MetadataResource:
	if file.is_empty(): return null
	
	var data :Dictionary[StringName,Variant]= MetadataHandler.GetMetadata(file)
	var metadata :MetadataResource= MetadataResource.new()
	
	metadata.artists = data.get("artists",[])
	metadata.album = data.get("album","")
	metadata.title = data.get("title","")
	metadata.art = data.get("art",false)
	
	updated_metadata.emit(metadata,file.get_file().get_basename())
	return metadata

func on_audio_file_clicked(file : String) -> void:
	if file.is_empty(): return
	
	match file.get_extension():
		"ogg":
			audio.stream = AudioStreamOggVorbis.load_from_file(file)
		"mp3":
			audio.stream = AudioStreamMP3.load_from_file(file)
		"wav":
			audio.stream = AudioStreamWAV.load_from_file(file)
	
	get_metadata(file)
	current_track_path = file
	
	audio.volume_db = -80
	create_tween().tween_property(audio,"volume_db",0,0.25)
	
	audio.play()

func get_formatted_time(time : float) -> String:
	var minutes :float= time / 60
	var seconds :float= fmod(time,60)
	return "%02d:%02d" % [minutes,seconds]

#Disabling for now, works, but is a bit buggy
#Code Taken From: 
#u/PhillyStein:
#https://www.reddit.com/r/godot/comments/18uzd3f/comment/lee0wjz/
#=====
#Set up a variable for the window size with the value as the default resolution. 
#var window_size :Vector2i= Vector2i(916, 515)
#
#func _process(_delta : float) -> void:
	## check to see if the window size changes
	#if DisplayServer.window_get_size() != window_size:
		## Get the current window width
		#var window_w :int= DisplayServer.window_get_size().x
		## Since the resolution is 16:9; to get the height, divide the width by 16 and multiply by 9
		## Or you can set the resolution width and 	height as variables, to suit other resolutions.
		#var window_h :int= window_w / 16.0 * 9
		## Set the window size to the current width and the new height
		#DisplayServer.window_set_size(Vector2i(window_w, window_h))
		## Change the window_size variable to match the new size
		#window_size = DisplayServer.window_get_size()
