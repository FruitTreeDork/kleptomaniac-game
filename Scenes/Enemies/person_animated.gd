extends RigidBody3D

@onready var animation_player: AnimationPlayer = $person_animated_loop/AnimationPlayer

var state : String = "idle"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("wave")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == "idle":
		animation_player.play("wave")
	else:
		animation_player.play("shmoving")


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.name == "drizzle":
		state = "detected"


func _on_detection_area_body_exited(body: Node3D) -> void:
	if body.name == "drizzle":
		state = "idle"
