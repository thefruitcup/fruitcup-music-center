extends ScrollContainer

const MAX_SONG_TITLE_CHARS :int= 24
const MAX_SONGS_PER_COLUMN :int= 4

@onready var grid_container :GridContainer= get_node("GridContainer")
@onready var light :PointLight2D= get_node("PointLight2D")
@onready var shader_material : ShaderMaterial = preload("res://shaders/text_gradient_fade_into_background.material")

var grid_container_clone :GridContainer

func _ready() -> void:
	grid_container_clone = grid_container.duplicate()
	Global.updated_directories.connect(update_grid)
	
	Console.add_command("update_grid",update_grid)
	

func update_grid() -> void:
	if grid_container.get_child_count() > 0:
		grid_container.queue_free()
		grid_container = grid_container_clone.duplicate()
		add_child(grid_container)
	
	for file : String in Global.all_music_files_loaded:
		var button :WMCButton= WMCButton.new()
		var music_name :String= file.get_file().get_basename()
		
		if music_name.length() > MAX_SONG_TITLE_CHARS:
			music_name = music_name.erase(MAX_SONG_TITLE_CHARS,music_name.length())
		
		button.text = music_name
		button.fire_on_button_down = false
		button.fire_on_button_up = false
		button.button_hovered_function = music_button_hover
		
		grid_container.add_child(button)
		
		button.label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		
		button.button_down.connect(Global.on_audio_file_clicked.bind(file))
		button.viewport_container.material = shader_material
	
	#add 1 or else the first column will have 5 songs instead of 4
	grid_container.columns = round(grid_container.get_child_count() / MAX_SONGS_PER_COLUMN) + 1

func music_button_hover(hovered : bool, button : WMCButton) -> void:
	button.label.label_settings.font_size = (18 if hovered else 16)
