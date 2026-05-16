extends Button
class_name WMCButton
##Essentially, normal Buttons as of Godot 4.6.1 do not let us add LabelSettings to Buttons.
##And this is the simplest and easiest way I know to get them working hassle free.
##Will eventually have to add a abstract method to allow for more customization on Hover and Non-Hover though


@export var fire_on_button_down : bool = true
@export var fire_on_button_up : bool = false
@export var label_settings : LabelSettings = LabelSettings.new()
@export var extra_label_settings :LabelExtraSettings= LabelExtraSettings.new()
@export var texture : Texture
@onready var viewport_container :SubViewportContainer
@onready var viewport :SubViewport
@onready var label : Label
@onready var texture_rect:TextureRect

##function should "func foo(hovered : bool, button : WMCButton) -> void"
var button_hovered_function : Callable

func _ready() -> void:
	
	if texture: _create_texture()
	else: _create_label_viewport()
	
	wmc_set_disabled(disabled)
	
	if fire_on_button_down: button_down.connect(on_press)
	if fire_on_button_up: button_up.connect(on_press)
	mouse_entered.connect(on_mouse_hover)
	mouse_exited.connect(on_mouse_left)

#Not intended for outside use
func _create_label_viewport() -> void:
	#doing all of this so text can look how it does in WMC, as putting a gradient shader applies it on the font's texture
	#not the text itself
	#this does (fortunately?) give us that blurry look when we fullscreen the window though
	viewport = SubViewport.new()
	viewport_container =SubViewportContainer.new()
	viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	viewport_container.add_child(viewport)
	viewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = true
	
	viewport.size = size
	viewport_container.size = size
	
	label = Label.new()
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	label.text =text
	label.label_settings = label_settings
	
	#because the text gives the button it's proper size for grid container & this is simple enough for now
	add_theme_color_override("font_color",Color.TRANSPARENT)
	add_theme_color_override("font_disabled_color",Color.TRANSPARENT)
	add_theme_color_override("font_focus_color",Color.TRANSPARENT)
	add_theme_color_override("font_hover_color",Color.TRANSPARENT)
	add_theme_color_override("font_pressed_color",Color.TRANSPARENT)
	add_theme_color_override("font_outline_color",Color.TRANSPARENT)
	viewport.add_child(label)
	add_child(viewport_container)

func _create_texture() -> void:
	texture_rect = TextureRect.new()
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.texture = texture
	texture_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(texture_rect)

func wmc_set_disabled(toggle : bool) -> void:
	disabled = toggle
	if label: label.modulate = (extra_label_settings.normal if !disabled else extra_label_settings.disable)
	if texture_rect:texture_rect.modulate = (extra_label_settings.normal if !disabled else extra_label_settings.disable)
	if button_hovered_function: button_hovered_function.call(false, self)

func on_mouse_hover() -> void:
	if disabled: return
	if label: label.modulate = extra_label_settings.hover
	if texture_rect:texture_rect.modulate = extra_label_settings.hover
	if button_hovered_function: button_hovered_function.call(true, self)

func on_mouse_left() -> void:
	if disabled: return
	label.modulate = extra_label_settings.normal
	if button_hovered_function: button_hovered_function.call(false, self)

func on_press() -> void:
	return
