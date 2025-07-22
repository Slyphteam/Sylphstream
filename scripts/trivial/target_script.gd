##Deprecated script, since I moved the generic "target hit" statement to the bullet reactive parent.
class_name testing_target extends RAYCASTREACTIVE
@onready var root:SCOREDTARGET = $"../.."
@onready var targetOrig = root.global_position.z 

func hit_By_Bullet(dam, damtype, dir, origin):
	#print(root.global_position.z)
	print("Target hit! ", dam)
	
	
	
	var move:float = randi_range(-20, 20) #frick floats, do integer steppings
	move /= 20
	if(move < 5 && move > -5): #don't move the target a small amount.
		move = randi_range(-20, 20)
	
	#side side
	root.global_position.z = clamp(targetOrig - 3, root.global_position.z + move, targetOrig + 3 )
	#forward back
	#move= randi_range(-20, 20) / 10
	#root.global_position.x = clamp(targetOrig - 3, root.global_position.zx+ move, targetOrig + 3 )
	
	root.totalHits +=1
