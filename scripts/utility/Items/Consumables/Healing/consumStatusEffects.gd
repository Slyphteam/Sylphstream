extends CONSUMEBEHAVIOR
# script for interpreting the aux info array as status effects

func activate(manager: INVENMANAGER, ourItem:INVENITEMPARENT) ->bool:
	
	var counter = 0
	for x in range(ourItem.extraData.size()/3):
		var newEffect = STATUSEFFECT.statusEffectGenerate(ourItem.extraData[counter], ourItem.extraData[counter+1], ourItem.extraData[counter+2])
		manager.healthHolder.add_Effect(newEffect)
		counter+=3
	return true
