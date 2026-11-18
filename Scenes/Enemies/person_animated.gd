extends RigidBody3D

@onready var animation_player: AnimationPlayer = $person_animated_loop/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("shmoving")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
