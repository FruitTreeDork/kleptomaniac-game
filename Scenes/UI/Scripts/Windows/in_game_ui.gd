extends Control


signal settings_toggled(is_toggled: bool)

@onready var the_player: player = $"../drizzle"


func _unhandled_input(event: InputEvent) -> void:
	var toggle = the_player.in_settings
	if event.is_action_pressed("esc"):
		if !toggle:
			settings_toggled.emit(true)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			settings_toggled.emit(false)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
