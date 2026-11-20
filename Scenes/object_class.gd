extends Node3D
class_name object


@export var obj_data: object_resource

var f : bool = false

func Throw(camera: Camera3D, speed : float):
	var direction = -camera.global_basis.z.normalized()
	self.linear_velocity = direction * speed

func Interact():
	pass
