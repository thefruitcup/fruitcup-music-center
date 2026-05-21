extends WMCButton

@export var tag : String= "artist"
@export var text_to_display : String
@export var looking_at_text :Label
@export var music_grid_display :MusicGridDisplay
var should_update :bool= true

func _ready() -> void:
	super()
	
	process_priority = -15 #as music grid has a priority of -16
	Global.updated_directories.connect(set.bind("should_update",true))

func on_press() -> void:
	if should_update:
		(Global.artists_files if tag == "artist" else Global.album_files).clear()
		
		if tag == "artist":
			Global.artists_files.assign(MusicGridDisplayHelper.ReturnArtists(Global.all_music_files_loaded))
		else:
			Global.album_files.assign(MusicGridDisplayHelper.ReturnAlbum(Global.all_music_files_loaded))
	
	music_grid_display.update_grid((Global.artists_files if tag == "artist" else Global.album_files).keys(),false,on_artist_button_pressed)
	looking_at_text.text = text_to_display
	
	should_update = false

func on_artist_button_pressed(artist : String) -> void:
	music_grid_display.update_grid((Global.artists_files if tag == "artist" else Global.album_files)[artist])
	var btn :WMCButton= await music_grid_display.create_button("< Back", func e(_file:String)->void:pass,false)
	btn.button_up.connect(on_press)
	looking_at_text.text = artist
	
	if btn && btn.get_parent() == music_grid_display: music_grid_display.move_child(btn,0)
