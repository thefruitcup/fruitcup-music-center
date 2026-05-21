extends Label

const MAX_CHAR_40 :int= 24
const MAX_CHAR_24 :int= 15

func _process(_delta: float) -> void:
	if text.length() > MAX_CHAR_24 && text.length() < MAX_CHAR_40:
		label_settings.font_size = 24
	elif text.length() > MAX_CHAR_40:
		label_settings.font_size = 16
	else:
		label_settings.font_size = 40
