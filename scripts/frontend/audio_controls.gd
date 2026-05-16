extends HBoxContainer

const MAX_SHUFFLE_ATTEMPTS :int= 4
const RESTART_MUSIC_TIME :float= 2

@onready var pause_btn :Button= get_node("pause")
@onready var stop_btn :Button= get_node("stop")
@onready var skipF_btn :Button= get_node("skipForward")
@onready var skipB_btn :Button= get_node("skipBack")
@onready var shuffle_btn :Button= get_node("shuffle")

var is_shuffle_enabled : bool = false

func _ready() -> void:
	pause_btn.button_down.connect(pause_audio)
	stop_btn.button_down.connect(stop_audio)
	skipF_btn.button_down.connect(skip)
	skipB_btn.button_down.connect(skip.bind(true))
	shuffle_btn.toggled.connect(shuffle)
	
	#dumb way to go to the next song, but works for now
	Global.audio.finished.connect(skip)

func pause_audio() -> void:
	Global.audio.stream_paused = !Global.audio.stream_paused

func stop_audio() -> void: 
	Global.audio.stop()
	Global.current_track_path = ""

func skip(backward : bool = false) -> void:
	if Global.all_music_files_loaded.size() <= 0: return 
	
	if backward && Global.audio.get_playback_position() > RESTART_MUSIC_TIME:
		Global.audio.seek(0)
		return
	
	if is_shuffle_enabled:
		shuffle_skip(backward)
		return
	
	var idx :int= Global.all_music_files_loaded.find(Global.current_track_path) + (1 if not backward else -1)
	
	if idx > Global.all_music_files_loaded.size() - 1: idx = 0
	if idx < 0: idx = Global.all_music_files_loaded.size() - 1
	
	Global.on_audio_file_clicked(Global.all_music_files_loaded[idx])

func shuffle_skip(backward : bool = false) -> void:
	var idx : int
	
	if !backward:
		idx = Global.all_music_files_loaded.find(Global.current_track_path)
		
		var attempts :int= 0
		
		while Global.all_music_files_loaded[idx] in Global.shuffle_queue:
			idx = randi_range(0,Global.all_music_files_loaded.size() - 1)
			attempts += 1
			if attempts >= MAX_SHUFFLE_ATTEMPTS: break
		
		Global.shuffle_queue.append(Global.all_music_files_loaded[idx])
		Global.on_audio_file_clicked(Global.all_music_files_loaded[idx])
	else: 
		idx = Global.shuffle_queue.find(Global.current_track_path) - 1
		
		if idx <= -1: #so we at least load something, even if it's not a randomly selected song
			idx = Global.all_music_files_loaded.find(Global.current_track_path) + (1 if not backward else -1)
			
			if idx > Global.all_music_files_loaded.size() - 1: idx = 0
			if idx < 0: idx = Global.all_music_files_loaded.size() - 1
		
		Global.on_audio_file_clicked(Global.shuffle_queue[idx])

func shuffle(value : bool) -> void:
	is_shuffle_enabled = value
	
	if !value: Global.shuffle_queue.clear()
	else: Global.shuffle_queue.append(Global.current_track_path)
	
