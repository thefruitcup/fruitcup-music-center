extends Label

const UNKNOWN_ARTIST :String= "Unknown Artist"

@onready var timeline :HScrollBar= get_node("timeline")

var current_metadata :Dictionary[String,String] = {
	"title": "",
	"album": "",
	"artist": ""
}

func _ready() -> void:
	Global.updated_metadata.connect(get_metadata)
	Global.get_metadata()
	update_display()

#NOTE: MP3ID3Tag isn't great at getting album and artist name despite WMC getting it right.
#Other Music Metadata Addons aren't great either due to being undocumented or outdated.
func get_metadata(data : MP3ID3Tag, default_title : String) -> void:
	var title :String= data.getTrackName()
	var artist :String= data.getArtist()
	var album :String= data.getAlbum()
	
	current_metadata["title"] = (title if !title.is_empty() else default_title)
	current_metadata["album"] = (album if !album.is_empty() else "")
	current_metadata["artist"] = (artist if !artist.is_empty() else UNKNOWN_ARTIST)
	


func update_display() -> void:
	if Global.current_track_path.is_empty():
		text = ""
		return
	
	
	text = current_metadata["title"] + " " + Global.get_formatted_time(Global.audio.get_playback_position())
	if !current_metadata["album"].is_empty(): text += "\n" + current_metadata["album"]
	text += "\n" + current_metadata["artist"]
	
	#TODO: add a function to have this occasionally appear like in WMC
	text += "\n" + Global.get_formatted_time(Global.audio.stream.get_length())
	
	get_window().title = current_metadata["title"] + " " + Global.get_formatted_time(Global.audio.get_playback_position()) + " | Fruitcup Music Center"

func _process(_delta: float) -> void:
	update_display()
