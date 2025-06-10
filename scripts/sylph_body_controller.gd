extends CharacterBody3D
@onready var sylphHead = $headholder


func move_Head(desired: Vector2):
	#TODO: in the future add inaccuracy with higher speeds
	move_Head_Exact(desired)

##Moves the Sylph's head with a vector containing the degrees of lift/drift desired.
func move_Head_Exact(desired: Vector2):
	var lift = desired.x
	var drift = desired.y
	sylphHead.rotation_degrees.x += lift
	sylphHead.rotation_degrees.y += drift
