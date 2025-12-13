extends RAYCASTREACTIVE
@export var thingToGive: INVENITEMPARENT #CHANGE THIS TO INVWEP

func interact_By_Player(player):
	do_consume(player)

func do_consume(player):
	var invem: INVENMANAGER = player.invenManager
	if invem.consume_item(thingToGive):
		var theRoot = $"../.."
		theRoot.queue_free()
	else:
		print("Not enough room!")
