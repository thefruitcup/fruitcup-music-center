extends Node

signal audio_file_clicked(path : String)
signal updated_directories
signal updated_metadata(data : MusicMetadata, default_title : String)
const SUPPORTED_FORMATS :Array[String]= ["ogg","wav","mp3"]
const PATH_META_STRING :String= "PATH"

var music_files_loaded :Array[PackedStringArray]=[]
var audio : AudioStreamPlayer

func _ready() -> void:
	audio = AudioStreamPlayer.new()
	add_child(audio)

func add_directory(dir_selected : String, files_in_dir : PackedStringArray) -> void:
	var music_files : PackedStringArray
	
	for file : String in files_in_dir:
		if file.get_extension() not in Global.SUPPORTED_FORMATS: continue
		music_files.append(dir_selected + "/" + file)
	
	music_files_loaded.append(music_files)
	updated_directories.emit()

func on_audio_file_clicked(file : String) -> void:
	match file.get_extension():
		"ogg":
			audio.stream = AudioStreamOggVorbis.load_from_file(file)
		"mp3":
			audio.stream = AudioStreamMP3.load_from_file(file)
		"wav":
			audio.stream = AudioStreamWAV.load_from_file(file)
	
	
	var metadata_array :Array= MusicMetadata.from_audio_stream_unpacked(audio.stream)
	
	if metadata_array.size() > 0:
		updated_metadata.emit(metadata_array[0],file.get_file().get_basename())
	
	audio.play()
