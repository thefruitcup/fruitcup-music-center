extends Button

@onready var file_dialog :FileDialog= get_node("FileDialog")
@onready var grid :GridContainer= get_parent().get_node("ScrollContainer/GridContainer")
@onready var audio :AudioStreamPlayer= get_parent().get_node("AudioStreamPlayer")
@onready var mmui :Control= get_parent().get_node("MusicMetadataUI")

const SUPPORTED_FORMATS :Array[String]= ["ogg","wav","mp3"]

func _ready() -> void:
	button_down.connect(on_press)
	file_dialog.dir_selected.connect(dir_select)

func on_press() -> void:
	file_dialog.popup_file_dialog()

func dir_select(dir_selected : String) -> void:
	var all_files :PackedStringArray= DirAccess.get_files_at(dir_selected)

	for node : Node in grid.get_children():
		node.queue_free()

	for file : String in all_files:
		if file.get_extension() not in SUPPORTED_FORMATS: continue

		var button :Button= Button.new()
		button.text = file
		button.set_meta("path",file)
		grid.add_child(button)
		button.button_down.connect(on_music_button_pressed.bind(dir_selected+"/"+file))

func on_music_button_pressed(file : String) -> void:
	print(file.get_extension())

	match file.get_extension():
		"ogg":
			audio.stream = AudioStreamOggVorbis.load_from_file(file)
		"mp3":
			audio.stream = AudioStreamMP3.load_from_file(file)
		"wav":
			audio.stream = AudioStreamWAV.load_from_file(file)
	
	var tags :Dictionary= {}
	var audio_bytes :PackedByteArray= MusicMetadataTools.bytes_from_audio(audio.stream)
	print(MusicMetadataTools.parse_id3_tags(audio_bytes,tags))
	audio.play()
