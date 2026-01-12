extends RAYCASTREACTIVE

func hit_By_Bullet(theDamInfo:DAMINFO):
	#print(root.global_position.z)
	
	var newHP = healthholder.take_DamInfo(theDamInfo)
	print("Target hit! ", theDamInfo.damage, " return: ", newHP, " true health: ", healthholder.health)
	if(newHP <= 0):
		var root = $"../.."
		root.queue_free()
