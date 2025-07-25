class_name PLAYERHEALTHHOLDER extends HEALTHHOLDER

func _init():
	process_mode = PROCESS_MODE_PAUSABLE

var aura: int

func take_Dam(incomingDam)->int:
	takenDamage += incomingDam
	var newHealth = curHealth - takenDamage
	if(newHealth <= 0):
		doDie()
	return newHealth

func _process(_delta: float) -> void:
	if(takenDamage != 0):
		curHealth -= takenDamage
		takenDamage = 0
		if(curHealth <= 0):
			doDie()

func doDie():
	return
