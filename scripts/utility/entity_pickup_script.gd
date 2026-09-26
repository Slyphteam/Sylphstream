##Support script for all pick-uppable items, must have an assigned thingToGive or they won't work
##why don't we cut out the middleman here? because the thingToGive nonetheless has to be stored on the target node.
class_name PICKUPABLE extends RAYCASTREACTIVE

@export var thingToGive: INVENITEMPARENT #CHANGE THIS TO INVWEP?

func _ready():
	if(thingToGive):
		thingToGive = thingToGive.duplicate(true) #ensure we are never operating with the "template" data
	update_Ammbox()

func update_Ammbox():
	if!(thingToGive is INVAMMBOX):
		return
	thingToGive.itemDesc = thingToGive.descFirstHalf + str(thingToGive.amount) + thingToGive.descSecondHalf

func interact_By_Player(player):
	
	do_consume(player)


func do_consume(player):
	var invem: INVENMANAGER = player.invenManager
	var result = invem.consume_item(thingToGive)
	
	if(thingToGive is INVAMMBOX): #special return-only check if there's leftovers in the ammo
		if(thingToGive.amount != 0):
			player.uiInfo.give_Chat_Message("Didn't pick up all the ammo! preserving box!")
			update_Ammbox()
			result = false

	if (result == true): #success
		var theRoot
		theRoot = $".."
		theRoot.queue_free()
		return true
	else:
		return false
