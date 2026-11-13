class_name inventory_box
extends Control

@export var icon: TextureRect
@export var obj_data: object_resource

func _ready() -> void:
	if obj_data != null:
		pass
		# icon.Texture = obj_data.texture or something 
