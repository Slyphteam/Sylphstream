extends CharacterBody3D
@onready var sylphHead = $"headholder/sylph head"
@onready var collider = $sylphcollider


func hit_By_Bullet(dam, damtype, dir, origin):
	#print("ow!")
	move_Head_Exact(Vector2(0,10))

func interact_By_Player():
	print("Hi bestie!!")
	move_Head_Exact(Vector2(0,-10))

func move_Head(desired: Vector2):
	#TODO: in the future add inaccuracy with higher speeds
	move_Head_Exact(desired)

##Moves the Sylph's head with a vector containing the degrees of lift/drift desired. X will rotate "down" and Y will rotate "left"
func move_Head_Exact(desired: Vector2):
	var lift = desired.x #not necessary to do this, but for legibility I am anyway
	var drift = desired.y
	sylphHead.rotation_degrees.x += lift
	sylphHead.rotation_degrees.y += drift
	var newangle = sylphHead.rotation_degrees.y
	
	var diff = newangle - collider.rotation_degrees.y
	if(abs(diff) > 40):
		collider.rotation_degrees.y = (newangle + collider.rotation_degrees.y) / 2
