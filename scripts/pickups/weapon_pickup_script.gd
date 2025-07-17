extends RAYCASTREACTIVE
@export var weptoGive: WEAP_INFO

func interact_By_Player(player):
	var invem: INVENMANAGER = player.invenManager
	if invem.give_New_Weapon(weptoGive, weptoGive.selections):
		var theRoot = $"../.."
		theRoot.queue_free()
	else:
		print("Not enough room!")
