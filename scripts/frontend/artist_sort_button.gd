extends WMCButton

@export var music_grid_display :MusicGridDisplay

func _ready() -> void:
	super()
	
	process_priority = -15 #as music grid has a priority of -16

func on_press() -> void:
	Global.artists_files.clear()
	var all_artists :PackedStringArray= []
	
	for file : String in Global.all_music_files_loaded:
		var get_artists :PackedStringArray= MetadataHandler.GetTag(file,"artist")
		
		for artist : String in get_artists:
			if !Global.artists_files.has(artist):
				Global.artists_files[artist] = [] as PackedStringArray
			
			Global.artists_files[artist].append(file) 
			all_artists.append(artist)
	
	#TODO: add artist button call function
	music_grid_display.update_grid(all_artists,false)
	
