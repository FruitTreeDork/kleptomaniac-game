extends CanvasLayer


@onready var bg_pan: Panel = $bg_pan

var fullscreen_toggle: bool = false

signal settings_toggled(is_toggled: bool)


func _ready() -> void:
	bg_pan.visible = false


func _unhandled_input(event: InputEvent) -> void:
	HandleSettingsActivation(event)


# Capturing Pause Menu and Making Mouse Cursor Visible
func HandleSettingsActivation(event: InputEvent):
	if event.is_action_pressed("esc"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			settings_toggled.emit(true)
			bg_pan.visible = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			settings_toggled.emit(false)
			bg_pan.visible = false


# Minimize Button Handling
func _on_minimize_button_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)


# Maximize Button Handling
func _on_maximize_button_pressed() -> void:
	if fullscreen_toggle:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		fullscreen_toggle = false
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		fullscreen_toggle = true


# Quit Button Handling
func _on_quit_button_pressed() -> void:
	get_tree().quit()
