extends CONSUMEBEHAVIOR


func activate(manager: INVENMANAGER, ourItem:INVENITEMPARENT) ->bool:
	var weights:Array
	
	for slot in manager.allSlots:
		for weapy in slot:
			if(weapy):
				if(weapy is INVWEP && weapy.weapInfoSheet is FIREARM_INFO):
					weights.push_back(weapy.weapInfoSheet.chambering)
	
	if(manager.activeItem is GUNBASICINSTANCE): #give a little more weight to what's held
		weights.push_back(manager.activeItem.weaponSheet.chambering)
	
	if(weights.size() == 0): #nothing equipped?
		return false
	
	var currentTyp
	var currentAmt
	for x in range(ourItem.extraData[0]): #poll from our ammotypes AUX amount of time
		
		
		currentTyp = weights.pick_random()
		
		if(currentTyp == 0):
			currentAmt = randi_range(10, 55)
		elif(currentTyp == 1):
			currentAmt = randi_range(8, 56)
		elif(currentTyp == 2):
			currentAmt = randi_range(8, 30)
		elif(currentTyp == 3):
			currentAmt = randi_range(4, 11)
		elif(currentTyp == 4):
			currentAmt = randi_range(3, 12)
		elif(currentTyp == 5):
			currentAmt = randi_range(5, 16)
		
		var giveResult = manager.giveAmmo(currentTyp, currentAmt)
		
		if(giveResult !=0): #we're low on space, stop
			break
	return true
	#if(thingToGive.consumBehavior == 2): #Status effect
		#if(thingToGive.consumAux == 0):
		#
		#else if (thingToGive.consumAux == 1):
		#else if (thingToGive.consumAux == 2):
		#else if (thingToGive.consumAux == 3):
		#else if (thingToGive.consumAux == ):
