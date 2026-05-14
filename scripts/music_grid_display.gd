extends ScrollContainer

@onready var grid_container :GridContainer= get_node("GridContainer")
var grid_container_clone :GridContainer

func _ready() -> void:
	grid_container_clone = grid_container.duplicate()
	
	Global.updated_directories.connect(update_grid)

func update_grid() -> void:
	if grid_container.get_child_count() > 0:
		grid_container.queue_free()
		grid_container = grid_container_clone.duplicate()
		add_child(grid_container)
	
	for music_file_arrays : PackedStringArray in Global.music_files_loaded:
		for file : String in music_file_arrays:
			var button :Button= Button.new()
			button.text = file.get_file().get_basename()
			grid_container.add_child(button)
			button.button_down.connect(Global.on_audio_file_clicked.bind(file))
	
