extends RichTextLabel

@export var display_info :MainScreenMusicInfo

var current_metadata :Dictionary[String,Variant] = {
	"title": "",
	"album": "",
	"artist": "",
	"art": false
}

func _ready() -> void:
	visibility_changed.connect(update_display)
	update_display()

func update_display() -> void:
	if Global.current_track_path.is_empty():
		text = "[font_size=20]No Track Playing[/font_size]"
		return
	
	current_metadata = display_info.current_metadata
	
	text = "[font_size=20]" + current_metadata["title"] + "[/font_size]"
	text += "\n[color=73add9][font_size=15]" + current_metadata["artist"]
	if !(current_metadata["album"] as String).is_empty(): text += "\n" + current_metadata["album"]
	#TODO: add a function to have this occasionally appear like in WMC
	text += "\n" + Global.get_formatted_time(Global.audio.get_playback_position()) + " | " + Global.get_formatted_time(Global.audio.stream.get_length()) + "[/font_size]"


func _process(_delta: float) -> void:
	update_display()
