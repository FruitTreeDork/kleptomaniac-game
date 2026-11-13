extends CharacterBody3D

class_name player


const HAND_STRENGTH: float = 25.0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003
const PUSH_FORCE = 2.0

const ARM_BACK : float = 200

var in_settings : bool = false
var left_hand_extend : bool = false
var right_hand_extend : bool = false
var left_hand_throwing : bool = false
var right_hand_throwing : bool = false
var left_hand_interact : bool = false
var right_hand_interact : bool = false
var left_hand_throw_start : bool = false

var left_hand_item : object
var right_hand_item : object

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

@onready var left_hand: Node3D = $Hands/LeftHand
@onready var right_hand: Node3D = $Hands/RightHand

@onready var left_hand_marker: Marker3D = $Head/Camera3D/MarkerLeftHand
@onready var right_hand_marker: Marker3D = $Head/Camera3D/MarkerRightHand

@onready var left_hand_area: Area3D = $Hands/LeftHand/LeftHandArea
@onready var right_hand_area: Area3D = $Hands/RightHand/RightHandArea

@onready var left_hand_coll: CollisionShape3D = $Hands/LeftHand/CollisionShape3D
@onready var right_hand_coll: CollisionShape3D = $Hands/RightHand/CollisionShape3D

@onready var right_hand_obj: Node3D = $Hands/RightHand/right_hand_obj
@onready var left_hand_obj: Node3D = $Hands/LeftHand/left_hand_obj
@onready var two_handed_obj_pos: Node3D = $Hands/RightHand/two_handed_obj_pos

@export var ingame_ui: Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ingame_ui.settings_toggled.connect(_on_settings_toggled)
	left_hand.visible = false
	right_hand.visible = false


func _unhandled_input(event: InputEvent) -> void:
	HandleMouseLook(event)


# Checks Settings signal from the InGameUI Scene If Mouse Cursor is Activated
func _on_settings_toggled(is_toggled: bool):
	in_settings = is_toggled


# Handles the Hand Nodes Following Camera (Since They Aren't Child Nodes)
func HandleHandFollow(hand: RigidBody3D, marker: Marker3D):
	var follow_pos = marker.global_position - hand.global_position
	hand.linear_velocity = (follow_pos * HAND_STRENGTH)
	hand.linear_velocity = (follow_pos * HAND_STRENGTH)

	var follow_rot = (marker.global_basis * hand.global_basis.inverse()).get_rotation_quaternion()
	hand.angular_velocity = follow_rot.get_axis() * follow_rot.get_angle() * HAND_STRENGTH


func _on_right_hand_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("objects") and body is object and !right_hand_item:
		var held_object : object = body
		if !held_object.obj_data.two_handed:
			held_object.reparent(right_hand_obj)
			held_object.position = held_object.obj_data.hand_offset
			held_object.rotation = Vector3.ZERO
			held_object.process_mode = Node.PROCESS_MODE_DISABLED
			held_object.obj_data.in_hand = true
			right_hand_item = held_object
		elif !left_hand_item:
			held_object.reparent(two_handed_obj_pos)
			held_object.position = held_object.obj_data.hand_offset
			held_object.rotation = Vector3.ZERO
			held_object.process_mode = Node.PROCESS_MODE_DISABLED
			held_object.obj_data.in_hand = true
			right_hand_item = held_object
			left_hand_item = held_object
			right_hand.visible = true
			left_hand.visible = true


func _on_left_hand_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("objects") and body is object and !left_hand_item:
		var held_object : object = body
		if !held_object.obj_data.two_handed:
			held_object.reparent(left_hand_obj)
			held_object.process_mode = Node.PROCESS_MODE_DISABLED
			held_object.position = Vector3(-held_object.obj_data.hand_offset.x, held_object.obj_data.hand_offset.y, held_object.obj_data.hand_offset.z)
			held_object.rotation = Vector3.ZERO
			held_object.obj_data.in_hand = true
			left_hand_item = held_object
		elif !right_hand_item:
			held_object.reparent(two_handed_obj_pos)
			held_object.position = held_object.obj_data.hand_offset
			held_object.rotation = Vector3.ZERO
			held_object.process_mode = Node.PROCESS_MODE_DISABLED
			held_object.obj_data.in_hand = true
			right_hand_item = held_object
			left_hand_item = held_object
			right_hand.visible = true
			left_hand.visible = true


func _physics_process(delta: float) -> void:
	# Adds the Gravity for Player
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# If Mouse Cursor isn't Activated, Player Input is Allowed
	if !in_settings:
		HandleInput()
	
	HandleHandFollow(left_hand, left_hand_marker)
	HandleHandFollow(right_hand, right_hand_marker)
	
	move_and_slide()
	
	HandleObjectCollision()


func HandleObjectCollision():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody3D:
			var push_dir = -collision.get_normal()
			push_dir.y = 0
			collider.apply_central_impulse(push_dir * PUSH_FORCE)


# Handles All Player Input 
func HandleInput():
	HandleWASDInput()
	HandleJump()
	HandleThrow()
	HandleItemDrop(left_hand_obj, left_hand_item, "drop_item_left")
	HandleItemDrop(right_hand_obj, right_hand_item, "drop_item_right")
	HandleHandExtend(left_hand, left_hand_area, left_hand_item, "left_click")
	HandleHandExtend(right_hand, right_hand_area, right_hand_item, "right_click")


# Obtains the WASD Input Direction and Velocity for Player
func HandleWASDInput():
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


# Capturing Mouse Look for Player
func HandleMouseLook(event: InputEvent):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(60))


# Handles Jumping for Player
func HandleJump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY


# Handles Extending Hand When Player is Holding Click or if Item is in Hand
func HandleHandExtend(hand: Node3D, hand_area: Area3D, hand_item: object, input: String):
	if Input.is_action_pressed(input):
		hand.visible = true
		hand_area.process_mode = Node.PROCESS_MODE_INHERIT
	elif !hand_item:
		hand.visible = false
		hand_area.process_mode = Node.PROCESS_MODE_DISABLED


# Handles Dropping the Item by Reparenting From the Hand to the World
func HandleItemDrop(hand_obj: Node3D, hand_item: object, input: String):
	if hand_item and Input.is_action_just_pressed(input) and !hand_item.obj_data.two_handed:
		hand_obj.get_child(0).process_mode = Node.PROCESS_MODE_INHERIT
		hand_obj.get_child(0).obj_data.in_hand = false
		hand_obj.get_child(0).reparent(self.get_parent())
		if hand_obj == left_hand_obj:
			left_hand_item = null
		else:
			right_hand_item = null
	elif hand_item and Input.is_action_just_pressed(input) and hand_item.obj_data.two_handed:
		two_handed_obj_pos.get_child(0).process_mode = Node.PROCESS_MODE_INHERIT
		two_handed_obj_pos.get_child(0).obj_data.in_hand = false
		two_handed_obj_pos.get_child(0).reparent(self.get_parent())
		right_hand_item = null
		left_hand_item = null


func HandleThrow():
	if Input.is_action_pressed("left_click") and left_hand_item:
		if !left_hand_throw_start:
			$LeftHandThrowTimer.start()
			left_hand_throw_start = true
		if $LeftHandThrowTimer.time_left > 2.5 and $LeftHandThrowTimer.time_left < 3:
			left_hand_interact = true
			left_hand_throwing = false
		else:
			left_hand_throwing = true
			left_hand_interact = false
	
	if Input.is_action_just_released("left_click") and left_hand_item:
		left_hand_throw_start = false
		$LeftHandThrowTimer.stop()
		
		if left_hand_throwing:
			left_hand_item.HandleThrow()
			HandleItemDrop(left_hand_obj, left_hand_item, "drop_item_left")
		elif left_hand_interact:
			left_hand_item.HandleInteract()
