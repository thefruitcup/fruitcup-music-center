extends ColorRect

var shader_material :ShaderMaterial= material
@export var max_falloff :float= 1.0
@export var max_amplitude :float= 0.02
@export var min_amplitude :float= 0.0

var amplitude : float
var left_falloff :float= 0
var right_falloff :float= 0
var gbl_delta : float = 0.033

func _ready() -> void:
	amplitude = max_amplitude
	var timer : Timer= Timer.new()
	add_child(timer)
	timer.timeout.connect(timeout)
	timer.wait_time = 0.05
	timer.start()

func _process(delta: float) -> void:
	gbl_delta = delta

func timeout() -> void:
	if !shader_material: return
	
	shader_material.set_shader_parameter("right_falloff",right_falloff)
	shader_material.set_shader_parameter("left_falloff",left_falloff)
	shader_material.set_shader_parameter("wave_amplitude",amplitude)
	
	if right_falloff <= 0: right_falloff += gbl_delta
	if right_falloff >= max_falloff: right_falloff -= gbl_delta
	
	if left_falloff <= 0: left_falloff += gbl_delta
	if left_falloff >= max_falloff: left_falloff -= gbl_delta
	
	if amplitude <= min_amplitude: amplitude += 0.1
	if amplitude >= max_amplitude: amplitude -= 0.1
	
