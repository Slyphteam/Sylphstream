extends RAYCASTREACTIVE

func hit_By_Bullet(dam, _damtype, _dir, _originator):
	#print(root.global_position.z)
	
	var newHP = healthholder.take_Dam(dam)
	print("Target hit! ", dam, " return: ", newHP, " true health: ", healthholder.health)
	if(newHP <= 0):
		var root = $"../.."
		root.queue_free()
