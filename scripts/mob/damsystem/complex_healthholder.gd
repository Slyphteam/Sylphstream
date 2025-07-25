class_name COMPLEXHEALTHHOLDER extends HEALTHHOLDER

func _init():
	process_mode = PROCESS_MODE_PAUSABLE

var aura: int = 50
var takenAura

func take_Dam(incomingDam)->int:
	
	if(aura > 0): #3/4ths of damage + remainder gets routed to aura.
		@warning_ignore("integer_division") var quarter = incomingDam / 4
		var remainder = incomingDam - (quarter * 4)
		var takenByAura = (quarter * 3) + remainder
		takenAura -= takenByAura
		
		incomingDam = quarter #the rest 4th we'll apply to health
		
		if(aura < 0): #aura fully depleted, check for leftover damage
			incomingDam -= takenAura
			takenAura = 0
		
		
	
	takenDamage += incomingDam
	var newHealth = health - takenDamage
	if(newHealth <= 0):
		doDie()
	return newHealth

func _process(_delta: float) -> void:
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
