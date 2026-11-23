extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $person_animated_loop/AnimationPlayer
@onready var ray_cast_3d: RayCast3D = $RayCast3D

const SPEED = 100

var health = 100

var target_body

enum {  idle = 0,
		walking = 1,
		too_close = 2,
	}


var state : int = idle

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("wave")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if state == idle:
		self.rotate_y(1* delta)
		animation_player.play("wave")
	elif state == walking || (ray_cast_3d.is_colliding() && ray_cast_3d.get_collider().name == "drizzle"):
		self.look_at(target_body.position)
		var dir = global_position.direction_to(target_body.global_position)
		velocity = dir * SPEED * delta
		move_and_slide()
		animation_player.play("shmoving")
	elif state == too_close:
		self.look_at(target_body.position)
		animation_player.play("wave")
	


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.name == "drizzle" and state != too_close:
		target_body = body
		state = walking


func _on_detection_area_body_exited(body: Node3D) -> void:
	if body.name == "drizzle":
		state = idle


func _on_too_close_body_entered(body: Node3D) -> void:
	if body.name == "drizzle":
		target_body = body
		state = too_close


func _on_too_close_body_exited(body: Node3D) -> void:
	if body.name == "drizzle":
		target_body = body
		state = walking
