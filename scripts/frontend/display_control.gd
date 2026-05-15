extends Label

@onready var timeline :HScrollBar= get_node("timeline")
@onready var pause :Button= get_node("pause")
@onready var stop :Button= get_node("stop")
@onready var skipF :Button= get_node("skipForward")
@onready var skipB :Button= get_node("skipBack")

func _ready() -> void:
	Global.updated_metadata.connect(update_display)
	pause.button_down.connect(pause_audio)
	stop.button_down.connect(stop_audio)

#NOTE: MusicMeta and MusicMetadata Addons don't work.
#MusicMeta only supports ID3 2.3.0 and MusicMetadata is just undocumented as hell
#This ain't great. I'm just gonna leave this here so the display is updated
func update_display(data : MP3ID3Tag, default_title : String) -> void:
	var title :String= data.getTrackName()
	var artist :String= data.getArtist()
	var album :String= data.getAlbum()
	
	text = (title if !title.is_empty() else default_title)
	text += "\n" + (album if !album.is_empty() else "Unknown Album")
	text += "\n" + (artist if !artist.is_empty() else "Unknown Artist")
	

func pause_audio() -> void:
	Global.audio.stream_paused = !Global.audio.stream_paused

func stop_audio() -> void: Global.audio.stop()
#func skip_forward() -> void: 
