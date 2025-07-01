extends CharacterBody3D
##Controller code for the Sylph. Relies on sylph_mind for inputs.
@onready var sylphHead = $"sylph head v2"
@onready var collider = $sylphcollider
@onready var mind = $"slyph mind"
@onready var manager : INVENMANAGER = $"sylph head v2/sylphinventory"



func hit_By_Bullet(_dam, _damtype, _dir, _origin):
	#print("ow!")
	move_Head_Exact(Vector2(5,5))

func interact_By_Player(playerRef)->bool:
	
#	#do_Single_Thought
	mind.do_Senses()
	
	#mind.load_From_File("res://resources/txt files/sylph tests/20 18 standstill shooting tests/loadingtest.txt")
	#mind.ourNetwork.mutate_Network(0.5, 0.01)
	#mind.save_To_File("res://resources/txt files/sylph tests/20 18 standstill shooting tests/loadingtest.txt")
	#print("saved!")
	

	return false

func move_Head(desired: Vector2, moveSpeed):
	#TODO: in the future add inaccuracy with higher speeds
	move_Head_Exact(desired)

##Moves the Sylph's head with a vector containing the degrees of rotation in vertical, horizontal
func move_Head_Exact(desired: Vector2):
	sylphHead.rotation_degrees.x += desired.x
	sylphHead.rotation_degrees.y += desired.y
	
	clampf(sylphHead.rotation_degrees.x, -90, 90)
	
	#This code would update the body's rotation, which looked cool, but isn't something I want to deal with yet
	#var newangle = sylphHead.rotation_degrees.y
	#
	#var diff = newangle - collider.rotation_degrees.y
	#if(abs(diff) > 40):
		#collider.rotation_degrees.y = (newangle + collider.rotation_degrees.y) / 2
