extends TextureRect

@export var cover_art :TextureRect

func _ready() -> void:
	visibility_changed.connect(on_visible)
	on_visible()

func on_visible() -> void:
	texture = cover_art.texture
