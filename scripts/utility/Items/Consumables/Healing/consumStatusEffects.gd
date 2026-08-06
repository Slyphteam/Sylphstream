extends CONSUMEBEHAVIOR
# script for interpreting the aux info array as status effects

func activate(manager: INVENMANAGER, ourItem:INVENITEMPARENT) ->bool:
	
	var counter = 0
	for x in range(ourItem.extraData.size()/2):
		var newEffect = STATUSEFFECT.statusEffectGenerate(ourItem.extraData[counter], ourItem.extraData[counter+1])
		manager.healthHolder.add_Effect(newEffect)
		counter+=2
	return true
