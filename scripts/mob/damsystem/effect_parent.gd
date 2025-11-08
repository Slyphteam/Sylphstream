##The parent class for status effects. Uses a doubly linked list to cleanly handle the possibility of frequent additions and removals.
#does NOT use resources, as each stim has its own custom script.
#Instead, change variables in the beginEffect function
class_name STATUSEFFECT extends Node

var effectName:String
var effectDesc:String

var ourHealthHolder: COMPLEXHEALTHHOLDER
var nextEffect: STATUSEFFECT = null
var prevEffect: STATUSEFFECT = null

var duration: float  = 1 ##In delta-adjusted frames. Modify during beginEffect.
var applyWindow: float = 60 ##What's the cooldown between each application? Modify during beginEffect.
var applyCountdown: float = applyWindow ##Counter until we apply our effect next. set to 1 to apply every frame

##Process an effect for 1 frame. Returns true if the effect expires.
func process_Effect(delta):
	var frameComp = delta * 60 #should be approx equal to 1
	
	applyCountdown -= frameComp
	if(applyCountdown <=0):
		applyCountdown = applyWindow #reset the countdown
		apply_Effect()
	
	duration -= frameComp
	
	if(nextEffect):
		nextEffect.process_Effect(delta)
	
	if(duration <= 0): #time's out!!
		
		 
		if(!prevEffect && !nextEffect): #special case, we were the final effect in the list.
			ourHealthHolder.effectStarter = null
		elif(!prevEffect && nextEffect): #special case. we are first in list, but there are more
			ourHealthHolder.effectStarter = nextEffect
			nextEffect.prevEffect = null
		elif(prevEffect && !nextEffect): #special case. last in list but others
			prevEffect.nextEffect = null
		else: #Otherwise, cut from list normally
			nextEffect.prevEffect = prevEffect
			prevEffect.nextEffect = nextEffect
		
		expire_Effect() #apply any expiration effects
		queue_free()
	

##passes a status effect until it hits the tail of the DLL
func add_To_Tail(newEffect: STATUSEFFECT):
	if(nextEffect):
		nextEffect.add_To_Tail(newEffect)
	else:
		newEffect.prevEffect = self
		nextEffect = newEffect

func check_For_Effect(targName:String)-> bool:
	if(effectName == targName): #target found
		return true
	else:
		if(nextEffect): #do we have a next?
			return nextEffect.check_For_Effect(targName) #go down the list
		else:
			return false #if we don't have a next, and we haven't found thus far, return false

#called when an effect begins
func begin_Effect():
	return

#called each applyWindow.
func apply_Effect():
	return

#called when an effect expires
func expire_Effect():
	return
