extends WMCButton

enum Status{
	IDLE,
	LOADING,
	FINISHED
}

@export var tag : String= "artist"
@export var text_to_display : String
@export var looking_at_text :Label
@export var music_grid_display :MusicGridDisplay
var should_update :bool= true
var music_grid_display_helper :MusicGridDisplayHelper
var updated_section :Status= Status.IDLE

func _ready() -> void:
	super()
	
	process_priority = -15 #as music grid has a priority of -16
	Global.updated_directories.connect(set.bind("should_update",true))
	
	music_grid_display_helper = MusicGridDisplayHelper.new()
	add_child(music_grid_display_helper)

func on_press() -> void:
	if updated_section == Status.LOADING: return
	
	if should_update:
		(Global.artists_files if tag == "artist" else Global.album_files).clear()
		
		if tag == "artist":
			music_grid_display_helper.ReturnArtists(Global.all_music_files_loaded)
		else:
			music_grid_display_helper.ReturnAlbum(Global.all_music_files_loaded)
		
		music_grid_display.stop_batch()
		music_grid_display.clear_grid()
		music_grid_display.clear_grid()
		music_grid_display.clear_grid()
		music_grid_display.create_button("Loading...", func e(_file:String)->void:pass,false)
		updated_section = Status.LOADING
		
		#because on fast computers, this should take around 3s, though
		#we definitely should add a signal from MGDH to signal when the batching is finished
		await get_tree().create_timer(3).timeout
	
	music_grid_display.update_grid((Global.artists_files if tag == "artist" else Global.album_files).keys(),false,on_artist_button_pressed)
	looking_at_text.text = text_to_display
	updated_section = Status.FINISHED
	
	should_update = false

func on_artist_button_pressed(artist : String) -> void:
	music_grid_display.update_grid((Global.artists_files if tag == "artist" else Global.album_files)[artist])
	var btn :WMCButton= await music_grid_display.create_button("< Back", func e(_file:String)->void:pass,false)
	btn.button_up.connect(on_press)
	looking_at_text.text = artist
	
	if btn && btn.get_parent() == music_grid_display: music_grid_display.move_child(btn,0)
