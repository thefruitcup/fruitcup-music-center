extends "res://scripts/backend/setup_settings.gd"

@onready var main :Control= get_node("../main")
@onready var startup :AudioStreamPlayer= get_node("startup")

func _ready() -> void:
	if UserPrefs.first_time:
		modulate = Color.TRANSPARENT
		main.hide()
		show()
		
		for i : int in 16:
			await get_tree().process_frame
		
		create_tween().tween_property(self,"modulate",Color(1,1,1,1),0.4)
		startup.play()
		super()
	else:
		main.show()
		queue_free()
