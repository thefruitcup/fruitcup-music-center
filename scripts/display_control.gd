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
	timeline.changed.connect(timeline_scrubbing)

func update_display(data : MusicMetadata, default_title : String) -> void:
	text = (data.title if !data.title.is_empty() else default_title)
	text += "\n" + (data.album if !data.album.is_empty() else "Unknown Album")
	text += "\n"
	
	if !data.artist.is_empty():
		text += data.artist
	elif !data.album_artist.is_empty():
		text += data.album_artist
	else:
		text += "Unknown Artist"

func pause_audio() -> void:
	if Global.audio.playing: Global.audio.stream_paused = !Global.audio.stream_paused
	else: Global.audio.play()

func stop_audio() -> void: Global.audio.stop()
#func skip_forward() -> void: 

func timeline_scrubbing() -> void:
	Global.audio.stream_paused = true
	Global.audio.seek(timeline.value)

func _process(_delta: float) -> void:
	if !Global.audio.playing || Global.audio.stream_paused: return
	
	timeline.max_value = Global.audio.stream.get_length()
	timeline.value = Global.audio.get_playback_position()
	
