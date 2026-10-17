extends CharacterBody3D


@export var left_hand_marker: Node3D
@export var right_hand_marker: Node3D

const HAND_STRENGTH: float = 25.0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

@onready var left_hand: Node3D = $Hands/LeftHand
@onready var right_hand: Node3D = $Hands/RightHand

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	left_hand.visible = false
	right_hand.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	
	if event.is_action_pressed("esc"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	# Using Left Hand
	if Input.is_action_pressed("left_click"):
		left_hand.visible = true
	else:
		left_hand.visible = false
	
	# Using Right Hand
	if Input.is_action_pressed("right_click"):
		right_hand.visible = true
	else:
		right_hand.visible = false
	
	HandleHandMovement(left_hand, left_hand_marker)
	HandleHandMovement(right_hand, right_hand_marker)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func HandleHandMovement(hand: RigidBody3D, marker: Marker3D):
	var follow_pos = marker.global_position - hand.global_position
	hand.linear_velocity = (follow_pos * HAND_STRENGTH)
	hand.linear_velocity = (follow_pos * HAND_STRENGTH)

	var follow_rot = (marker.global_basis * hand.global_basis.inverse()).get_rotation_quaternion()
	hand.angular_velocity = follow_rot.get_axis() * follow_rot.get_angle() * HAND_STRENGTH
