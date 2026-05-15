extends WMCButton

@onready var file_dialog :FileDialog= get_node("FileDialog")
@onready var grid :GridContainer= get_parent().get_node("ScrollContainer/GridContainer")
@onready var audio :AudioStreamPlayer= get_parent().get_node("AudioStreamPlayer")

func _ready() -> void:
	super()
	
	file_dialog.dir_selected.connect(dir_select)
	Console.add_command("add_dir",dir_select,["dir"],1)

func on_press() -> void:
	file_dialog.popup_file_dialog()

func dir_select(dir_selected : String) -> void:
	Global.add_directory(dir_selected, DirAccess.get_files_at(dir_selected))
