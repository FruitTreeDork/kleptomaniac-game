@tool
class_name bevel
extends Control

const OUTER_BEVEL_SIZE = 1
const INNER_BEVEL_SIZE = -1

@export var is_inverted := false
@export var fill := Color.WHITE
@export var light := Color.WHITE
@export var face := Color("d4d0c8")
@export var shadow := Color("808080")
@export var dark := Color("404040")

# Inverts light/shadow direction of the bevel, used for hover and buttons
func invert_bevel(invert: bool) -> void:
	is_inverted = invert
	queue_redraw()

func _ready() -> void:
	# For tool usage specifically 
	resized.connect(queue_redraw)

func _draw() -> void:
	var box := Rect2(Vector2.ZERO, size)
	if is_inverted: 
		_draw_border(box, light, dark)
		_draw_border(box.grow(INNER_BEVEL_SIZE), face, shadow)
	else:
		_draw_border(box, shadow, light)
		_draw_border(box.grow(INNER_BEVEL_SIZE), dark, face)

func _draw_border(box: Rect2, top_left: Color, bottom_right: Color) -> void:
	draw_rect(Rect2(box.position, Vector2(box.size.x, OUTER_BEVEL_SIZE)), top_left)
	draw_rect(Rect2(box.position, Vector2(1, box.size.y)), top_left)
	draw_rect(Rect2(box.position.x, box.end.y - OUTER_BEVEL_SIZE, box.size.x, OUTER_BEVEL_SIZE), bottom_right)
	draw_rect(Rect2(box.end.x - OUTER_BEVEL_SIZE, box.position.y, OUTER_BEVEL_SIZE, box.size.y), bottom_right)
