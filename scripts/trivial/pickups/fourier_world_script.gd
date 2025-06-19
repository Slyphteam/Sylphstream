extends raycast_reactive
@export var weptoGive: WEAPON_PARENT

func interact_By_Player(player):
	var invem: INVENMANAGER = player.invenManager
	invem.heldItem.load_weapon(weptoGive, true)
	return true
