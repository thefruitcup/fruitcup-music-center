extends Button

@onready var file_dialog :FileDialog= get_node("FileDialog")
@onready var grid :GridContainer= get_parent().get_node("ScrollContainer/GridContainer")
@onready var audio :AudioStreamPlayer= get_parent().get_node("AudioStreamPlayer")
@onready var label :Label= get_parent().get_node("Label")


func _ready() -> void:
	button_down.connect(on_press)
	file_dialog.dir_selected.connect(dir_select)

func on_press() -> void:
	file_dialog.popup_file_dialog()

func dir_select(dir_selected : String) -> void:
	Global.add_directory(dir_selected, DirAccess.get_files_at(dir_selected))
