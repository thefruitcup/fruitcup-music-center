extends WMCButton

@export var attribution_display :RichTextLabel
@export_multiline  var attribution_text :String

func on_press() -> void:
	var tween :PropertyTweener= create_tween().tween_property(attribution_display,"modulate",Color.TRANSPARENT,0.25)
	await tween.finished
	attribution_display.text = attribution_text
	tween = create_tween().tween_property(attribution_display,"modulate",Color(1,1,1,1),0.25)
	
