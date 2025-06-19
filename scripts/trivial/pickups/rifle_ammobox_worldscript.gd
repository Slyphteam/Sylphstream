extends raycast_reactive


func interact_By_Player(player):
	var invem: INVENMANAGER = player.invenManager
	#Give 20 rifle rounds. a little on the low side but hey that's what small boxes have in them
	invem.giveAmmo(2, 20) 
	
	var boxOrigin = $"../.."
	
	boxOrigin.queue_free() #delete full tree
	
	return true
