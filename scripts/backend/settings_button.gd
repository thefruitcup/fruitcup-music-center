extends WMCButton

##Setting that'll be changed in UserPrefs.settings
@export var setting :String
@export var value_on :Variant
@export var value_off :Variant

var init_string :String

func _ready() -> void:
	super()
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	init_string = label.text
	label.text = (init_string if !UserPrefs.settings.get(setting,false) else init_string + " [On]")

func on_press() -> void:
	UserPrefs.settings[setting] = (value_on if button_pressed else value_off)
	label.text = (init_string if !button_pressed else init_string + " [On]")
	Global.updated_directories.emit()
