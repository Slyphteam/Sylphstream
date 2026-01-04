class_name PICKUPABLE extends RAYCASTREACTIVE
@export var thingToGive: INVENITEMPARENT #CHANGE THIS TO INVWEP

func interact_By_Player(player):
	do_consume(player)

func do_consume(player):
	var invem: INVENMANAGER = player.invenManager
	if invem.consume_item(thingToGive.duplicate()):
		var theRoot
		#if(thingToGive.itemTyp == "WEP"):
		theRoot = $".."
		theRoot.queue_free()
		#else:
			#theRoot = $"../.."
			#theRoot.queue_free()
		
	else:
		print("Not enough room!")
