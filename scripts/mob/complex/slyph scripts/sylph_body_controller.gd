extends CharacterBody3D
##Controller code for the Sylph. Relies on sylph_mind for inputs.
@onready var sylphHead = $"sylph head v2"
@onready var collider = $sylphcollider
@onready var mind = $"slyph mind"
@onready var manager : INVENMANAGER = $"sylph head v2/sylphinventory"


var shoot = false
func hit_By_Bullet(_dam, _damtype, _dir, _origin):
	#print("ow!")
	if(shoot):
		manager.unShoot()
		shoot = false
	else:
		manager.doShoot()
		shoot = true
	
	#move_Head_Exact(Vector2(5,5))

func interact_By_Player(playerRef):
	
	mind.do_Vision()
	
	
	#mind.load_From_File("res://resources/txt files/sylph tests/20 18 standstill shooting tests/loadingtest.txt")
	#mind.ourNetwork.mutate_Network(0.5, 0.01)
	#mind.save_To_File("res://resources/txt files/sylph tests/20 18 standstill shooting tests/loadingtest.txt")
	#print("saved!")
	



##Moves the Sylph's head with a vector containing the degrees of rotation in vertical, horizontal
func move_Head_Exact(desired: Vector2):
	sylphHead.rotation_degrees.x -= desired.y
	sylphHead.rotation_degrees.y += desired.x
	
	clampf(sylphHead.rotation_degrees.x, -90, 90)
	
	#This code would update the body's rotation, which looked cool, but isn't something I want to deal with yet
	#var newangle = sylphHead.rotation_degrees.y
	#
	#var diff = newangle - collider.rotation_degrees.y
	#if(abs(diff) > 40):
		#collider.rotation_degrees.y = (newangle + collider.rotation_degrees.y) / 2
