extends CharacterBody3D
@onready var sylphHead = $"sylph head v2"
@onready var collider = $sylphcollider
@onready var visionblockR: Area3D = $"sylph head v2/triangleR"

func hit_By_Bullet(_dam, _damtype, _dir, _origin):
	#print("ow!")
	move_Head_Exact(Vector2(0,10))

func interact_By_Player(playerRef)->bool:
	do_Target_Test()
	
	
	return false


func do_Target_Test():
	if(visionblockR.has_overlapping_bodies()):
		
		var items: Array = visionblockR.get_overlapping_bodies()
		var x:int = 0
		while(x < items.size()):
			if(items[x] is testing_target):
				print("found something!")
				print(items[x])
			
			x+=1

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
