extends ScrollContainer

const MAX_SONG_TITLE_CHARS :int= 24
const AUTO_GRADIENT_TITLE_CHARS :int= 4
const MAX_SONGS_PER_COLUMN :int= 4

const MUSIC_BUTTON_NORMAL_FONT_SIZE :int= 16
const MUSIC_BUTTON_HOVER_FONT_SIZE :int= 17

@onready var grid_container :GridContainer= get_node("GridContainer")
@onready var shader_material : ShaderMaterial = preload("res://shaders/text_gradient_fade_into_background.material")
@onready var batch_creation_timer :Timer= get_node("batch_creation_timer")

@export var extra_label_settings : LabelExtraSettings = LabelExtraSettings.new()
var grid_container_clone :GridContainer
var current_sub_grid_container :GridContainer
var last_index_load : int = 0

var start_time :float

func _ready() -> void:
	grid_container_clone = grid_container.duplicate()
	Global.updated_directories.connect(update_grid)
	
	Console.add_command("update_grid",update_grid)
	update_grid()

func update_grid() -> void:
	if grid_container.get_child_count() > 0:
		grid_container.queue_free()
		grid_container = grid_container_clone.duplicate()
		add_child(grid_container)
	
	if Global.all_music_files_loaded.size() <= 0: return
	
	current_sub_grid_container = GridContainer.new()
	grid_container.add_child(current_sub_grid_container)
	
	start_time = Time.get_unix_time_from_system()
	Console.print_multiple("\n\nStart Time: ",start_time)
	
	last_index_load = 0
	batch_creation_timer.start()

func _on_batch_creation_timer_timeout() -> void:
	for index : int in 16:
		if last_index_load >= Global.all_music_files_loaded.size() - 1:
			break
		
		var file :String= Global.all_music_files_loaded[last_index_load]
		
		var button :WMCButton= WMCButton.new()
		var music_name :String= file.get_file().get_basename()
		var add_gradient : bool = false
		
		if music_name.length() >= AUTO_GRADIENT_TITLE_CHARS:
			add_gradient = true
		
		if music_name.length() > MAX_SONG_TITLE_CHARS:
			music_name = music_name.erase(MAX_SONG_TITLE_CHARS,music_name.length())
			
		
		button.text = music_name
		button.fire_on_button_down = false
		button.fire_on_button_up = false
		button.button_hovered_function = music_button_hover
		button.extra_label_settings = extra_label_settings
		
		current_sub_grid_container.add_child(button)
		
		button.label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		#Labels within Viewports don't recieve the Parent's Theme
		#Should really fix this within WMCButton, but this works for now and I'm a little tired of
		#getting the gradient to work and now look like complete shit
		button.label.theme = (get_parent().get_parent() as Control).theme
		
		button.button_down.connect(Global.on_audio_file_clicked.bind(file))
		
		if add_gradient: button.viewport_container.material = shader_material.duplicate(true)
		
		if (current_sub_grid_container.get_child_count() == MAX_SONGS_PER_COLUMN):
			current_sub_grid_container = GridContainer.new()
			grid_container.add_child(current_sub_grid_container)
		
		#to force the shader & color to apply
		button.on_mouse_left()
		music_button_hover(false,button)
		
		last_index_load += 1
	
	#add 1 or else the first column will have 5 songs instead of 4
	grid_container.columns = grid_container.get_child_count()
	
	if last_index_load >= Global.all_music_files_loaded.size() - 1:
		var end_time :float= Time.get_unix_time_from_system()
		Console.print_multiple("End Time: ",end_time)
		Console.print_multiple("Total Time: ",(end_time - start_time),"s")
		Console.print_multiple("Loaded: ",Global.all_music_files_loaded.size()," music files")
		batch_creation_timer.stop()

func music_button_hover(hovered : bool, button : WMCButton) -> void:
	button.label.label_settings.font_size = (MUSIC_BUTTON_HOVER_FONT_SIZE if hovered else MUSIC_BUTTON_NORMAL_FONT_SIZE)
	
	var current_shader_material :ShaderMaterial= button.viewport_container.material
	if not current_shader_material: return
	
	current_shader_material.set_shader_parameter("modulate",button.label.modulate)
