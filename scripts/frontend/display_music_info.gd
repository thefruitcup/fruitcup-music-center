extends RichTextLabel
class_name MainScreenMusicInfo

const UNKNOWN_ARTIST :String= "Unknown Artist"
const APPDATA_ALBUM_PATH :String= "user://album.png"
const DEFAULT_COVERS_PATH :String= "res://assets/textures/defaults/covers"

@onready var timeline :HScrollBar= get_node("timeline")
@onready var transition_button :TransitionButton= get_node("transition_button")
@onready var cover_art_tex_rect :TextureRect= get_node("../cover_art")
@onready var default_album_covers :PackedStringArray

var update_cover_art_now :bool= false
var is_over_cover_art :bool= false

var current_metadata :Dictionary[String,Variant] = {
	"title": "",
	"album": "",
	"artist": "",
	"art": false
}

func _ready() -> void:
	for file : String in ResourceLoader.list_directory(DEFAULT_COVERS_PATH):
		if !file.ends_with(".png"): continue
		
		default_album_covers.append(file)
	
	cover_art_tex_rect.mouse_entered.connect(set.bind("is_over_cover_art",true))
	cover_art_tex_rect.mouse_entered.connect(cover_art_tex_rect.set.bind("modulate",Color(0.5,0.5,0.5,1.0)))
	cover_art_tex_rect.mouse_exited.connect(set.bind("is_over_cover_art",false))
	cover_art_tex_rect.mouse_exited.connect(cover_art_tex_rect.set.bind("modulate",Color(1.0,1.0,1.0,1.0)))
	
	Global.updated_metadata.connect(get_metadata)
	Global.get_metadata()
	update_display()

#NOTE: MP3ID3Tag isn't great at getting album and artist name despite WMC getting it right.
#Other Music Metadata Addons aren't great either due to being undocumented or outdated.
func get_metadata(data : MetadataResource, default_title : String) -> void:
	var title :String= data.title
	var artists :PackedStringArray= data.artists
	var album :String= data.album
	var artist_full :String= ""
	var art :bool= data.art
	
	var artist_index :int= 0
	for artist : String in artists:
		artist_full += artist + (" " if artist_index <= 1 || artist_index >= artists.size() - 1 else ", ")
		artist_index += 1
	
	current_metadata["album"] = (album if !album.is_empty() else "")
	
	#artist & title metadata were found
	if !artist_full.is_empty() && !title.is_empty() && UserPrefs.settings.get("clear_artist_filename",false):
		for artist : String in artists:
			if !title.contains(artist): continue
			var string_substringing :String
			
			if title.contains(artist + " - "): string_substringing = artist + " - "
			else: string_substringing = artist
			
			Console.print_multiple(title.substr(string_substringing.length()))
			title = title.substr(string_substringing.length())
	
	#no artist metadata
	if artist_full.is_empty() && UserPrefs.settings.get("use_filename_artist",false): #using strings is dumb as fuck, but i can't really think of a better way to do this without const hell
		var idx :int= default_title.find(" -")
		
		if idx != -1:
			artist_full = default_title.substr(0, idx)
			
			if !artist_full.is_empty() && title.is_empty():
				title = default_title.substr(idx + 2)
				if title.begins_with(" "):
					title = title.substr(1)
	
	
	current_metadata["artist"] = (artist_full if !title.is_empty() else UNKNOWN_ARTIST)
	current_metadata["title"] = (title if !title.is_empty() else default_title)
	
	
	current_metadata["art"] = art
	update_cover_art_now = false

func update_cover_art(path : String) -> void:
	var img_tex :Texture2D
	
	if path.begins_with("res"):
		img_tex = load(path)
	else:
		var img :Image= Image.load_from_file(path)
		img_tex = ImageTexture.create_from_image(img)
	
	cover_art_tex_rect.texture = img_tex

func update_display() -> void:
	if Global.current_track_path.is_empty():
		text = ""
		return
	
	if !update_cover_art_now:
		if current_metadata["art"]: update_cover_art(ProjectSettings.globalize_path(APPDATA_ALBUM_PATH))
		else: update_cover_art(DEFAULT_COVERS_PATH + "/" + default_album_covers[randi_range(0, default_album_covers.size() - 1)])
		
		update_cover_art_now = true
	
	text = current_metadata["title"]# + " " + Global.get_formatted_time(Global.audio.get_playback_position())
	#if !(current_metadata["album"] as String).is_empty(): text += "\n" + current_metadata["album"]
	text += "\n[color=73add9]" + current_metadata["artist"]
	
	#TODO: add a function to have this occasionally appear like in WMC
	#text += "\n" + Global.get_formatted_time(Global.audio.stream.get_length())
	
	get_window().title = current_metadata["title"] + " " + Global.get_formatted_time(Global.audio.get_playback_position()) + " | Fruitcup Music Center"

func _process(_delta: float) -> void:
	update_display()
	
	if is_over_cover_art:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			transition_button.on_press()
