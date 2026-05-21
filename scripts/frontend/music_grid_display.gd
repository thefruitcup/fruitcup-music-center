extends ScrollContainer
class_name MusicGridDisplay

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
var music_files_to_load :PackedStringArray= Global.all_music_files_loaded
var is_music_files :bool= true
var music_button_call :Callable= Global.on_audio_file_clicked

func _ready() -> void:
	process_priority = -16
	grid_container_clone = grid_container.duplicate()
	Global.updated_directories.connect(update_grid)
	
	Console.add_command("update_grid",update_grid)
	if Global.dirs_music_loaded.size() <= 0: return
	await get_tree().process_frame
	update_grid()

func clear_grid() -> void:
	if grid_container.get_child_count() > 0:
		grid_container.queue_free()
		grid_container = grid_container_clone.duplicate()
		add_child(grid_container)
	
	current_sub_grid_container = GridContainer.new()
	grid_container.add_child(current_sub_grid_container)


func update_grid(
		music_files :PackedStringArray= Global.all_music_files_loaded, 
		load_music_files :bool= true,
		callable :Callable= Global.on_audio_file_clicked
) -> void:
	
	clear_grid()
	
	start_time = Time.get_unix_time_from_system()
	Console.print_multiple("\n\nStart Time: ",start_time)
	
	
	music_files_to_load = music_files
	is_music_files = load_music_files
	music_button_call = callable
	
	if is_music_files: Global.current_queue_playing = music_files_to_load
	
	last_index_load = 0
	batch_creation_timer.start()

func stop_batch() -> void:
	batch_creation_timer.stop()
	
	#so the current batch in process stops once it thinks we're over the limit (yes, adding 1 was not enough and 16 came next)
	last_index_load = music_files_to_load.size() + 16

#Weird, sometimes this function lags the fuck out of FMC,
#and other times it doesn't. Should figure out why that is
func _on_batch_creation_timer_timeout() -> void:
	for index : int in 16:
		if last_index_load > music_files_to_load.size() - 1:
			break
		
		var file :String= music_files_to_load[last_index_load]
		create_button(file)
		
		last_index_load += 1
	
	#add 1 or else the first column will have 5 songs instead of 4
	grid_container.columns = grid_container.get_child_count()
	
	if last_index_load >= music_files_to_load.size() - 1:
		var end_time :float= Time.get_unix_time_from_system()
		Console.print_multiple("End Time: ",end_time)
		Console.print_multiple("Total Time: ",(end_time - start_time),"s")
		Console.print_multiple("Loaded: ",music_files_to_load.size()," music files")
		batch_creation_timer.stop()
	
	await get_tree().process_frame

func music_button_hover(hovered : bool, button : WMCButton) -> void:
	button.label.label_settings.font_size = (MUSIC_BUTTON_HOVER_FONT_SIZE if hovered else MUSIC_BUTTON_NORMAL_FONT_SIZE)
	
	var current_shader_material :ShaderMaterial= button.viewport_container.material
	if not current_shader_material: return
	
	current_shader_material.set_shader_parameter("modulate",button.label.modulate)

func create_button(file : String, callable :Callable= music_button_call, this_is_a_music_file:bool= is_music_files) -> WMCButton:
	var button :WMCButton= MusicGridDisplayHelper.CreateButton(file, UserPrefs.settings.get("use_metadata_title_for_buttons",false) && this_is_a_music_file)
	
	var add_gradient : bool = false
	
	if button.text.length() >= AUTO_GRADIENT_TITLE_CHARS:
		add_gradient = true
	
	if button.text.length() > MAX_SONG_TITLE_CHARS:
		button.text = button.text.erase(MAX_SONG_TITLE_CHARS,button.text.length())
	
	button.fire_on_button_down = false
	button.fire_on_button_up = false
	button.button_hovered_function = music_button_hover
	button.extra_label_settings = extra_label_settings
	button.viewport_padding = Vector2(16,0)
		
	current_sub_grid_container.add_child(button)
	
	button.label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	#Labels within Viewports don't recieve the Parent's Theme
	#Should really fix this within WMCButton, but this works for now and I'm a little tired of
	#getting the gradient to work and not look like complete shit
	button.label.theme = (get_parent().get_parent() as Control).theme
	
	button.button_down.connect(callable.bind(file))
	if this_is_a_music_file:
		button.button_down.connect(highlight_track_playing)
	
	if add_gradient: button.viewport_container.material = shader_material.duplicate(true)
	
	if (current_sub_grid_container.get_child_count() == MAX_SONGS_PER_COLUMN):
		current_sub_grid_container = GridContainer.new()
		grid_container.add_child(current_sub_grid_container)
	
	#if is_music_files: highlight_track_playing(current_sub_grid_container)
	
	#to force the shader & color to apply
	button.on_mouse_left()
	music_button_hover(false,button)
	return button

func highlight_track_playing(sub_container : GridContainer) -> void:
	for button : WMCButton in sub_container.get_children():
		button.extra_label_settings.normal = extra_label_settings.normal
		if button.label.text == Global.current_track_path.get_file().get_basename():
			button.extra_label_settings.normal = extra_label_settings.toggled
