##Deprecated script, since I moved the generic "target hit" statement to the bullet reactive parent.
class_name testing_target extends raycast_reactive
@onready var root:Node3D = $"../.."

func hit_By_Bullet(dam, damtype, dir, origin):

	print("Target hit! ", dam)
	var move:float = randi_range(-5, 5)
	var distance: float = move / 10
	root.global_position.z += distance
