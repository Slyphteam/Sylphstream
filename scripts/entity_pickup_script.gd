##Support script for all pick-uppable items, must have an assigned thingToGive or they won't work
class_name PICKUPABLE extends RAYCASTREACTIVE

@export var thingToGive: INVENITEMPARENT #CHANGE THIS TO INVWEP

func _ready():
	thingToGive = thingToGive.duplicate() #ensure we are never operating with the "template" data

func interact_By_Player(player):
	do_consume(player)


func do_consume(player):
	var invem: INVENMANAGER = player.invenManager
	var result = invem.consume_item(thingToGive)
	
	if(thingToGive is INVAMMBOX): #special return only check if there's leftovers in the ammo
		for val in thingToGive.amtArr: #the invenmanager will update the held item's counts of ammo
			if(val != 0):
				print("Didn't pick up all the ammo! preserving box!")
				return

	if (result == true): #success
		var theRoot
		#if(thingToGive.itemTyp == "WEP"):
		theRoot = $".."
		theRoot.queue_free()
	#elif( && result is int):
	#	print("bazinga???")
	
	else:
		print("Not enough room!")
