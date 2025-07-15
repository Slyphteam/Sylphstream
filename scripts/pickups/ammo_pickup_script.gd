extends RAYCASTREACTIVE
@export var typeToGive: int
@export var amtToGive: int
func interact_By_Player(player):
	var invem: INVENMANAGER = player.invenManager
	invem.giveAmmo(typeToGive, amtToGive) 
	
	var boxOrigin = $"../.."
	boxOrigin.queue_free() #delete not only self, but also the full ammobox scene tree
	
