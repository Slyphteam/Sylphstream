##The parent class for status effects. Uses a doubly linked list
#to cleanly handle the possibility of frequent additions and removals.
class_name STATUSEFFECT extends Node

var duration: float ##In delta-adjusted frames
var ourHealthHolder: COMPLEXHEALTHHOLDER
var nextEffect: STATUSEFFECT = null
var prevEffect: STATUSEFFECT = null


@export var applyWindow: float = 60 ##What's the cooldown between each application?
var applyCountdown: float = applyWindow ##Counter until we apply our effect next. set to 1 to apply every frame

##Process an effect for 1 frame. Returns true if the effect expires.
func processEffect(delta):
	var frameComp = delta * 60 #should be approx equal to 1
	
	applyCountdown -= frameComp
	if(applyCountdown <=0):
		applyCountdown = applyWindow #reset the countdown
		applyEffect()
	
	duration -= frameComp
	
	if(nextEffect):
		nextEffect.processEffect(delta)
	
	if(duration <= 0):
		
		prevEffect.nextEffect = nextEffect
		nextEffect.prevEffect = prevEffect
		
		if(!prevEffect && !nextEffect): #special case, we were the final effect in the list.
			ourHealthHolder.effectStarter = null
		expireEffect() #apply any expiration effects
		queue_free()
	
	

#called when an effect begins
func beginEffect():
	return

#called each applyWindow.
func applyEffect():
	return

#called when an effect expires
func expireEffect():
	return
