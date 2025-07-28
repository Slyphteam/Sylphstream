class_name COMPLEXHEALTHHOLDER extends HEALTHHOLDER

func _init():
	process_mode = PROCESS_MODE_PAUSABLE

var aura: int = 0
var takenAura: int = 0 ##What's the damage applied to aura for the frame?

var effectStarter: STATUSEFFECT ##Head of the doubly linked list used to handle statuseffects.

func take_Dam(incomingDam)->int:
	
	if(aura > 0): #3/4ths of damage + remainder gets routed to aura.
		@warning_ignore("integer_division") var quarter = incomingDam / 4
		var remainder = incomingDam - (quarter * 4)
		var takenByAura = (quarter * 3) + remainder ##how much of the incoming damage are we metering to aura?
		
		if(takenByAura > aura): #aura will be depleted
			var overAura = takenByAura - aura
			takenByAura -= overAura #reduce takenbyaura by the overdamage
			#incomingDam += overAura #add to hp damage
		
		#actually add our calculated value to the aura loss
		takenAura += takenByAura 
		#reduce hp loss by whatever's diverted to aura
		incomingDam -= takenByAura 
		

	#whatever happens with aura is finished happening. The value left in incomingdam 
	#will now affect health.
	takenDamage += incomingDam
	var newHealth = health - takenDamage
	if(newHealth <= 0):
		doDie()
	return newHealth

func _process(_delta: float) -> void:
	handleEffects(_delta)
	
	if(takenDamage != 0 || takenAura != 0):
		update_True_Vals()

func update_True_Vals():
	health -= takenDamage
	aura -= takenAura
	takenDamage = 0
	takenAura = 0
	if(health <= 0):
		doDie()

func doDie():
	return
#
#func giveEffect

#Since status effects use a doubly linked list, all we have to do is call process on the first one,
#and it'll go down the chain and handle things. Clean and efficient!
func handleEffects(_delta):
	if(effectStarter):
		effectStarter.processEffect(_delta)
