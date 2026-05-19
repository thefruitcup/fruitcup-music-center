@tool
extends TextureRect

@export var location:String
@export_tool_button("Export Texture") var export_func :Callable= Callable(export)

func export() -> void:
	var img :Image= texture.get_image()
	print(img.save_png(location))
	
