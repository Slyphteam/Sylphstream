extends raycast_reactive
@export var weptoGive: WEAP_INFO

func interact_By_Player(player):
	var invem: INVENMANAGER = player.invenManager
	invem.heldItem.load_weapon(weptoGive, true)
	return true
