extends Label

const UNKNOWN_ARTIST :String= "Unknown Artist"

@onready var timeline :HScrollBar= get_node("timeline")
@onready var cover_art_tex_rect :TextureRect= get_node("../cover_art")

var update_cover_art :bool= false

var current_metadata :Dictionary[String,Variant] = {
	"title": "",
	"album": "",
	"artist": "",
	"art": []
}

func _ready() -> void:
	Global.updated_metadata.connect(get_metadata)
	Global.get_metadata()
	update_display()

#NOTE: MP3ID3Tag isn't great at getting album and artist name despite WMC getting it right.
#Other Music Metadata Addons aren't great either due to being undocumented or outdated.
func get_metadata(data : MetadataResource, default_title : String) -> void:
	var title :String= data.title
	var artists :PackedStringArray= data.artists
	var album :String= data.album
	var artist_full : String = ""
	var art :Array[int] = data.art
	
	var artist_index :int= 0
	for artist : String in artists:
		artist_full += artist + (" " if artist_index <= 1 || artist_index >= artists.size() - 1 else ", ")
		artist_index += 1
	
	current_metadata["title"] = (title if !title.is_empty() else default_title)
	current_metadata["album"] = (album if !album.is_empty() else "")
	current_metadata["artist"] = (artist_full if !artist_full.is_empty() else UNKNOWN_ARTIST)
	current_metadata["art"] = art
	update_cover_art = false


func update_display() -> void:
	if Global.current_track_path.is_empty():
		text = ""
		return
	
	if !update_cover_art && !(current_metadata["art"] as Array).is_empty():
		var bytes :Array[int]= (current_metadata["art"] as Array[int])
		var png_signature :Array[int]= [137, 80, 78, 71]
		var current_format :Image.Format
		var width :int
		var height :int
		
		var is_png :int= 0
		
		#such a stupid method of detecting if this is a png, but it works well enough
		for idx : int in png_signature.size():
			if bytes[idx] == png_signature[idx]: is_png += 1
		
		if is_png >= 4:
			width = bytes[18] * 256
			height = bytes[22] * 256
			
			#if bitdepth is 8 and color type is RGBA (aka 6)
			if bytes[24] == 8 && bytes[25] == 6:
				current_format = Image.FORMAT_RGBA8
		
		var img :Image= Image.create_from_data(width,height,false,current_format,bytes)
		
		
		var img_tex :ImageTexture= ImageTexture.create_from_image(img)
		
		cover_art_tex_rect.texture = img_tex
		update_cover_art = true
	
	text = current_metadata["title"] + " " + Global.get_formatted_time(Global.audio.get_playback_position())
	if !(current_metadata["album"] as String).is_empty(): text += "\n" + current_metadata["album"]
	text += "\n" + current_metadata["artist"]
	
	#TODO: add a function to have this occasionally appear like in WMC
	text += "\n" + Global.get_formatted_time(Global.audio.stream.get_length())
	
	get_window().title = current_metadata["title"] + " " + Global.get_formatted_time(Global.audio.get_playback_position()) + " | Fruitcup Music Center"

func _process(_delta: float) -> void:
	update_display()
