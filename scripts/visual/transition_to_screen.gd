extends WMCButton
class_name TransitionButton

@export var transition_from : Control
@export var transition_to : Control
var is_transitioning :bool=false

func on_press() -> void:
	is_transitioning = true
	transition_to.modulate = Color.TRANSPARENT
	transition_to.show()
	
	var tween :PropertyTweener= create_tween().tween_property(transition_from,"modulate",Color.TRANSPARENT,0.5)
	
	await tween.finished
	transition_from.hide()
	transition_to.show()
	
	tween = create_tween().tween_property(transition_to,"modulate",Color(1,1,1,1),0.5)
	is_transitioning = false
