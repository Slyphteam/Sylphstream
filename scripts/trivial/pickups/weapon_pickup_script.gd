extends raycast_reactive
@export var weptoGive: WEAP_INFO

func interact_By_Player(player):
	var invem: INVENMANAGER = player.invenManager
	invem.load_Wep(weptoGive)
	return true
