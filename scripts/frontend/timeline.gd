extends HScrollBar
class_name MusicTimeline

#TODO:
#1: figure out a way to make audio crackling less apparent when scrubbing through the timeline.
#2: making clicking on any point in the timeline automatically bring you there instead of progress there
#3: make it not look bad

#NOTE:
#This is a bit of a dilemma, Windows Media Center doesn't do Timelines
#So either I do:
#1. the faithful route and not include a timeline
#2. the original route and include a timeline
#3. add a setting, but it most likely wont be supported as well

var is_mouse_hovering : bool = false
func _ready() -> void:
	value_changed.connect(timeline_scrubbing)
	mouse_entered.connect(set.bind("is_mouse_hovering",true))
	mouse_exited.connect(set.bind("is_mouse_hovering",false))
	

func timeline_scrubbing(new_value : float) -> void:
	if !is_mouse_hovering: return
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): return
	Global.audio.seek(new_value)

func _process(_delta: float) -> void:
	if !Global.audio.playing || Global.audio.stream_paused: return
	
	max_value = Global.audio.stream.get_length()
	value = Global.audio.get_playback_position()
	
