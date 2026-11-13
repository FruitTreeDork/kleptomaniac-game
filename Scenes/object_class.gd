extends Node3D
class_name object


@export var obj_data: object_resource

var f : bool = false

func HandleThrow():
	self.linear_velocity = Vector3(0.0, 5, 10)

func HandleInteract():
	pass
