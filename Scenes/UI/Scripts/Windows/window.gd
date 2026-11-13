extends Control
class_name DraggableWindow

const WINDOW_SCALE: float = 0.35
const MIN_VISIBLE_MARGIN: float = 25.0
const MIN_BAR_SIZE: float = 20.0

@export var window_title: String
@export var content_scene: PackedScene
@export var window_container: PanelContainer
@export var window_bar: Control
@export var window_slot: Control 
@export var window_label: RichTextLabel
@export var min_size := Vector2.ZERO * WINDOW_SCALE 
@export var clamp_to_viewport := true

var _dragging := false
var _drag_offset := Vector2.ZERO

func _ready() -> void:
	_set_title(window_title)
	if min_size == Vector2.ZERO:
		min_size = get_viewport_rect().size * WINDOW_SCALE 
	window_container.custom_minimum_size = min_size
	window_container.size = min_size
	#window_bar.custom_minimium_size.y = MIN_BAR_SIZE
	#window_bar.size.y = MIN_BAR_SIZE
	_set_title(window_title)
	if content_scene:
		window_slot.add_child(content_scene.instantiate())

func _set_title(title: String) -> void: 
	window_label.text = title 
	
func _clamp_position() -> void: 
	var curr_viewport = get_viewport_rect().size
	global_position.x = clampf(global_position.x, -size.x + MIN_VISIBLE_MARGIN, curr_viewport.x - MIN_VISIBLE_MARGIN)
	global_position.y = clampf(global_position.y, 0.0, curr_viewport.y - MIN_VISIBLE_MARGIN)
	
func _input(event: InputEvent) -> void:
	# Bring window to the front 
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and get_global_rect().has_point(get_global_mouse_position()):
			move_to_front()
		else:
			_dragging = false
	# Move window around 
	elif event is InputEventMouseMotion:
		if _dragging:
			global_position = get_global_mouse_position() - _drag_offset
			if clamp_to_viewport:
				_clamp_position()

func _on_window_bar_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_dragging = true 
		_drag_offset = get_global_mouse_position() - global_position
