extends Node3D

var dore_area : bool
var dore_open : bool
@onready var anim: AnimationPlayer = $anim

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("left_click") and dore_area and !dore_open and !anim.is_playing():
		dore_open = true
		anim.play("open")
	elif Input.is_action_pressed("left_click") and dore_area and dore_open and !anim.is_playing():
		dore_open = false
		anim.play_backwards("open")
	

func _on_area_3d_area_entered(area: Area3D) -> void:
	dore_area = true


func _on_area_3d_area_exited(area: Area3D) -> void:
	dore_area = false
