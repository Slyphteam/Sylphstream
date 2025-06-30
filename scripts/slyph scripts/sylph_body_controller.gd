extends CharacterBody3D
##Controller code for the Sylph. Relies on sylph_mind for inputs.
@onready var sylphHead = $"sylph head v2"
@onready var collider = $sylphcollider
@onready var mind = $"slyph mind"
@onready var manager : INVENMANAGER = $"sylph head v2/sylphinventory"



func hit_By_Bullet(_dam, _damtype, _dir, _origin):
	#print("ow!")
	move_Head_Exact([5,5])

func interact_By_Player(playerRef)->bool:
	
	mind.do_Vision()

	return false

func move_Head(desired: Array):
	#TODO: in the future add inaccuracy with higher speeds
	move_Head_Exact(desired)

##Moves the Sylph's head with a vector containing the degrees of rotation in vertical, horizontal
func move_Head_Exact(desired: Array):
	var lift = desired[0] #not necessary to do this, but for legibility I am anyway
	var drift = desired[1]
	sylphHead.rotation_degrees.x += lift
	sylphHead.rotation_degrees.y += drift
	
	#This code would update the body's rotation, which looked cool, but isn't something I want to deal with yet
	#var newangle = sylphHead.rotation_degrees.y
	#
	#var diff = newangle - collider.rotation_degrees.y
	#if(abs(diff) > 40):
		#collider.rotation_degrees.y = (newangle + collider.rotation_degrees.y) / 2
