extends CharacterBody3D

class_name player



### UI ###
@onready var bg_pan: Panel = $ui/bg_pan


@export var left_hand_marker: Node3D
@export var right_hand_marker: Node3D

const HAND_STRENGTH: float = 25.0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

const ARM_BACK : float = 200

var in_settings : bool = false
var left_hand_extend : bool = false
var right_hand_extend : bool = false

var left_hand_item : object
var right_hand_item : object

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

@onready var left_hand: Node3D = $Hands/LeftHand
@onready var right_hand: Node3D = $Hands/RightHand

@onready var left_hand_area: Area3D = $Hands/LeftHand/LeftHandArea
@onready var right_hand_area: Area3D = $Hands/RightHand/RightHandArea

@onready var left_hand_coll: CollisionShape3D = $Hands/LeftHand/CollisionShape3D
@onready var right_hand_coll: CollisionShape3D = $Hands/RightHand/CollisionShape3D

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	left_hand.visible = false
	right_hand.visible = false
	bg_pan.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))
	
	if event.is_action_pressed("esc"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			in_settings = true
			bg_pan.visible = true
			
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			in_settings = false
			bg_pan.visible = false
			
			


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	if right_hand_item:
		pass
	

	if !in_settings:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		# Using Left Hand
		if Input.is_action_pressed("left_click"):
			left_hand.visible = true
			left_hand_area.process_mode = Node.PROCESS_MODE_INHERIT
			left_hand_extend = true
		elif !left_hand_item:
			left_hand.visible = false
			left_hand_area.process_mode = Node.PROCESS_MODE_DISABLED
			left_hand_extend = false
	
		# Using Right Hand
		if Input.is_action_pressed("right_click"):
			right_hand.visible = true
			right_hand_area.process_mode = Node.PROCESS_MODE_INHERIT
			right_hand_extend = true
		elif !right_hand_item:
			right_hand.visible = false
			right_hand_area.process_mode = Node.PROCESS_MODE_DISABLED
			right_hand_extend = false
		
		if left_hand_item and Input.is_action_just_pressed("drop_item_left"):
			left_hand_item = null
		if right_hand_item and Input.is_action_just_pressed("drop_item_right"):
			right_hand_item = null
	
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
	
	if !in_settings:
		move_and_slide()


func HandleHandMovement(hand: RigidBody3D, marker: Marker3D):
	var follow_pos = marker.global_position - hand.global_position
	hand.linear_velocity = (follow_pos * HAND_STRENGTH)
	hand.linear_velocity = (follow_pos * HAND_STRENGTH)

	var follow_rot = (marker.global_basis * hand.global_basis.inverse()).get_rotation_quaternion()
	hand.angular_velocity = follow_rot.get_axis() * follow_rot.get_angle() * HAND_STRENGTH


func _on_right_hand_area_body_entered(body: Node3D) -> void:
	#print("Hello from the right hand: ", body)
	if body.is_in_group("objects") and body is object_area:
		var to_parent = body.my_object
		print("Hello from the right hand: ", body)
		#while get_parent() != null:
		right_hand_item = to_parent
#		right_hand_item.owner = right_hand
		print(to_parent.name)
		print("PARENT: ", right_hand_item)
		


func _on_left_hand_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("objects"):
		var to_parent = body.my_object
		print("Hello from the left hand: ", body)
		#while get_parent() != null:
		left_hand_item = to_parent
		print(to_parent.name)
		print("PARENT: ", right_hand_item)


func _on_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
