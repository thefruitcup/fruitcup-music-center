extends Control

@onready var container :VBoxContainer= get_node("ColorRect/VBoxContainer")
@onready var dir_display :Label= get_node("dir_display")
@onready var add_directory_button :WMCButton=get_node("add_directory")
@onready var remove_directory_button :WMCButton=get_node("remove_directory")
@onready var file_dialog :FileDialog=get_node("add_directory/FileDialog")

var selected_dir :String

func _ready() -> void:
	visibility_changed.connect(update_display)
	file_dialog.dir_selected.connect(dir_select)
	add_directory_button.button_down.connect(add_directory)
	remove_directory_button.button_down.connect(remove_directory)
	update_display()

#i think this is ONLY called when we become visible
func update_display() -> void:
	for child : Node in container.get_children(): 
		child.queue_free()
	
	for dir : String in Global.dirs_music_loaded.keys():
		var label :WMCButton= WMCButton.new()
		label.text = dir + " (" + str(Global.dirs_music_loaded[dir].size()) + " tracks loaded)"
		label.size += Vector2(8,0)
		
		label.button_down.connect(on_dir_button_pressed.bind(label))
		label.set_meta("dir",dir)
		
		container.add_child(label)

func on_dir_button_pressed(button : WMCButton) -> void:
	selected_dir = button.get_meta("dir","nil")
	dir_display.text = "Directory Selected:\n" + selected_dir


func add_directory() -> void:
	file_dialog.popup_file_dialog()

func remove_directory() -> void:
	if selected_dir.is_empty(): return
	
	Global.remove_dir(selected_dir)
	selected_dir = ""
	
	dir_display.text = "Directory Selected:"
	
	update_display()

func dir_select(dir_selected : String) -> void:
	Global.add_directory(dir_selected, DirAccess.get_files_at(dir_selected))
	update_display()

func _on_bugreport_button_down() -> void:
	OS.shell_open("https://github.com/thefruitcup/fruitcup-music-center/issues")
