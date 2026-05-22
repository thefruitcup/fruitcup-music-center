extends Control

@onready var windows_font :SystemFont= preload("res://assets/misc/windows_font.tres")
@onready var fallback_font :FontFile= preload("res://assets/misc/NotoSans-Regular.ttf")

func _ready() -> void:
	Console.add_command("set_window_font",set_font.bind(windows_font))
	Console.add_command("set_fallback_font",set_font.bind(fallback_font))
	
	if OS.get_name() == "Windows": return
	set_font(fallback_font)

func set_font(font : Font) -> void:
	theme.default_font = font
	theme.set("Button/fonts/font",font)

func force_update() -> void:
	Global.updated_directories.emit()
