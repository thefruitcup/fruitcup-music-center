extends HBoxContainer

const MAX_SHUFFLE_ATTEMPTS :int= 4
const RESTART_MUSIC_TIME :float= 2

@onready var pause_btn :Button= get_node("pause")
@onready var stop_btn :Button= get_node("stop")
@onready var skipF_btn :Button= get_node("skipForward")
@onready var skipB_btn :Button= get_node("skipBack")
@onready var shuffle_btn :Button= get_node("shuffle")
@onready var volume_up_btn :Button= get_node("volumeup")
@onready var volume_down_btn :Button= get_node("volumedown")

func _ready() -> void:
	pause_btn.button_down.connect(pause_audio)
	stop_btn.button_down.connect(stop_audio)
	skipF_btn.button_down.connect(skip)
	skipB_btn.button_down.connect(skip.bind(true))
	shuffle_btn.toggled.connect(shuffle)
	volume_up_btn.button_down.connect(volume_up)
	volume_down_btn.button_down.connect(volume_down)
	
	#dumb way to go to the next song, but works for now
	Global.audio.finished.connect(skip)

func pause_audio() -> void:
	if !Global.audio.stream_paused:
		var t :PropertyTweener= create_tween().tween_property(Global.audio,"volume_db",-80,0.25)
		await  t.finished
	else:
		create_tween().tween_property(Global.audio,"volume_db",0,0.25)
	
	Global.audio.stream_paused = !Global.audio.stream_paused
	

func stop_audio() -> void: 
	Global.audio.stop()
	Global.current_track_path = ""

func skip(backward : bool = false) -> void:
	if Global.current_queue_playing.size() <= 0: return 
	
	if backward && Global.audio.get_playback_position() > RESTART_MUSIC_TIME:
		Global.audio.seek(0)
		return
	
	if Global.is_shuffle_enabled:
		shuffle_skip(backward)
		return
	
	var idx :int= Global.current_queue_playing.find(Global.current_track_path) + (1 if not backward else -1)
	
	if idx > Global.current_queue_playing.size() - 1: idx = 0
	if idx < 0: idx = Global.current_queue_playing.size() - 1
	
	Global.on_audio_file_clicked(Global.current_queue_playing[idx])

func shuffle_skip(backward : bool = false) -> void:
	var idx : int
	var queue :PackedStringArray= Global.current_queue_playing
	
	if !Global.current_track_path in queue:
		Global.shuffle_queue.clear()
	
	if !backward:
		idx = queue.find(Global.current_track_path)
		
		var attempts :int= 0
		
		while queue[idx] in Global.shuffle_queue:
			idx = randi_range(0,queue.size() - 1)
			attempts += 1
			if attempts >= MAX_SHUFFLE_ATTEMPTS: break
		
		Global.shuffle_queue.append(queue[idx])
		Global.on_audio_file_clicked(queue[idx])
	else: 
		idx = Global.shuffle_queue.find(Global.current_track_path) - 1
		
		if idx <= -1: #so we at least load something, even if it's not a randomly selected song
			idx = queue.find(Global.current_track_path) + (1 if not backward else -1)
			
			if idx > queue.size() - 1: idx = 0
			if idx < 0: idx = queue.size() - 1
			Global.on_audio_file_clicked(queue[idx])
		else:
			Global.on_audio_file_clicked(Global.shuffle_queue[idx])
		

func volume_up() -> void:AudioServer.set_bus_volume_db(0,min(6,AudioServer.get_bus_volume_db(0) + 1))
func volume_down() -> void:AudioServer.set_bus_volume_db(0,max(-80,AudioServer.get_bus_volume_db(0) - 1))

func shuffle(value : bool) -> void:
	Global.is_shuffle_enabled = value
	
	if !value: Global.shuffle_queue.clear()
	else: Global.shuffle_queue.append(Global.current_track_path)
	
