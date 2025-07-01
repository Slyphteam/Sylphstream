extends Node
var datapanel
var timer : float ##Global timer.

func _process(delta):
	timer += delta 

##Same weighted probability from layer script. Takes input 0-1, returns chance of 1-99
func weighted_Prob(chance)->bool:
	chance = absf(chance) #Can take negative inputs
	#Rather than going from 0-100% on 0-1, instead fo from 1-99. Therefore, the range is
	#actually 0-98 + 1
	var val = int(chance * 98) + 1
	var targ = randi_range(0, 100)
	if(val >= targ):
		return true
	
	return false
