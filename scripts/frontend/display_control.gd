extends Label

const UNKNOWN_ARTIST :String= "Unknown Artist"
const UNKNOWN_ALBUM :String= "Unknown Album"

@onready var timeline :HScrollBar= get_node("timeline")
@onready var pause :Button= get_node("pause")
@onready var stop :Button= get_node("stop")
@onready var skipF :Button= get_node("skipForward")
@onready var skipB :Button= get_node("skipBack")

var current_metadata :Dictionary[String,String] = {
	"title": "",
	"album": "",
	"artist": ""
}

func _ready() -> void:
	Global.updated_metadata.connect(get_metadata)
	pause.button_down.connect(pause_audio)
	stop.button_down.connect(stop_audio)
	skipF.button_down.connect(skip_forward)
	skipB.button_down.connect(skip_backward)

#NOTE: MusicMeta and MusicMetadata Addons don't work.
#MusicMeta only supports ID3 2.3.0 and MusicMetadata is just undocumented as hell
#This ain't great. I'm just gonna leave this here so the display is updated
func get_metadata(data : MP3ID3Tag, default_title : String) -> void:
	var title :String= data.getTrackName()
	var artist :String= data.getArtist()
	var album :String= data.getAlbum()
	
	current_metadata["title"] = (title if !title.is_empty() else default_title)
	current_metadata["album"] = (album if !album.is_empty() else UNKNOWN_ALBUM)
	current_metadata["artist"] = (artist if !artist.is_empty() else UNKNOWN_ARTIST)
	


func update_display() -> void:
	
	text = current_metadata["title"] + " " + Global.get_formatted_time(Global.audio.get_playback_position())
	text += "\n" + current_metadata["album"]
	text += "\n" + current_metadata["artist"]
	
	#TODO: add a function to have this occasionally appear like in WMC
	text += "\n" + Global.get_formatted_time(Global.audio.stream.get_length())

func pause_audio() -> void:
	Global.audio.stream_paused = !Global.audio.stream_paused

func stop_audio() -> void: Global.audio.stop()
func skip_forward() -> void:
	var idx :int= Global.all_music_files_loaded.find(Global.current_track_path) + 1
	
	if idx > Global.all_music_files_loaded.size() - 1: idx = 0
	Global.on_audio_file_clicked(Global.all_music_files_loaded[idx])

func skip_backward() -> void:
	var idx :int= Global.all_music_files_loaded.find(Global.current_track_path) - 1
	
	if idx < 0: idx = Global.all_music_files_loaded.size() - 1
	Global.on_audio_file_clicked(Global.all_music_files_loaded[idx])


func _process(delta: float) -> void:
	if !Global.audio.playing: return
	
	update_display()
