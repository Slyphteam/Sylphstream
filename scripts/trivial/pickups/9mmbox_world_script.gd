extends raycast_reactive

func interact_By_Player(player):
	var invem: INVENMANAGER = player.invenManager
	#give 50 rounds of 9mm, the standard amoutn in a "small" box. (sh/c)ould be reduced for balance
	invem.giveAmmo(1, 50) 
	print("bye")
	
	var boxOrigin = $"../.."
	boxOrigin.queue_free() #delete not only self, but also the full ammobox scene tree
