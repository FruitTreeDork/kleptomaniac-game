extends object

class_name bottle


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass




func _on_area_3d_area_entered(area: Area3D) -> void:
	print("Hello!: ", area.name)
	if the_player.name == "drizzle" and the_player.left_hand_extend and area.name == "LeftHandArea":
		print("In Left Hand")
		self.visible = false
		if !the_player.left_hand_item:
			the_player.left_hand_item = self
	if the_player.name == "drizzle" and the_player.right_hand_extend and area.name == "RightHandArea":
		print("In Right Hand")
		self.visible = false


func _on_area_3d_area_exited(area: Area3D) -> void:
	print("Bye Bye!: ", area)
