##Special script for the sylph testing targets. They're fun to shoot for players as well.
class_name testing_target extends RAYCASTREACTIVE
@onready var root:SCOREDTARGET = $"../.."
@onready var targetOrig = root.global_position

func hit_By_Bullet(theDamInfo:DAMINFO):
	#print(root.global_position.z)
	print("Target hit! ", theDamInfo.damage)
	
	
	
	var move:float = randi_range(-10, 10) #frick floats, do integer steppings
	@warning_ignore("integer_division") move /= 10
	#if(move < 5 && move > -5): #don't move the target a small amount.
		#move = randi_range(-20, 20)
	 
	#side side
	root.global_position.z += move
	root.global_position.z = clamp(root.global_position.z + move, targetOrig.z - 3,  targetOrig.z + 3 )
	#forward back
	#@warning_ignore("integer_division") move= randi_range(-20, 20) / 10
	#root.global_position.x += move
	#root.global_position.x = clamp(root.global_position.x + move, targetOrig.x - 3, targetOrig.x + 3 )
	
	root.totalHits +=1
