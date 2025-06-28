##Deprecated script, since I moved the generic "target hit" statement to the bullet reactive parent.
class_name testing_target extends raycast_reactive
@onready var root:SCOREDTARGET = $"../.."
@onready var targetOrig = root.global_position.z 

func hit_By_Bullet(dam, damtype, dir, origin):

	print("Target hit! ", dam)
	var move:float = randi_range(-20, 20)
	if(move < 5 && move > -5): #don't move the target a small amount.
		move = randi_range(-20, 20)
	var distance: float = move / 10
	
	root.global_position.z = clamp(targetOrig - 2, root.global_position.z + distance, targetOrig + 2 )
	
	root.totalHits +=1
