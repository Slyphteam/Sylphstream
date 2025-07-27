class_name HEALTHHOLDER extends Node
#worth doing: think about changing this to not update on process.
#This will mean you can't have "batch" damage (i.e. grouped shotgun hits)
#but it will make it simpler and cheaper codewise
func _init():
	process_mode = PROCESS_MODE_PAUSABLE

var health: int = 100
var takenDamage: int = 0 ##What's the damage we're applying to health for the frame?

func take_Dam(incomingDam)->int:
	takenDamage += incomingDam
	var newHealth = health - takenDamage
	if(newHealth <= 0):
		doDie()
	return newHealth

func _process(_delta: float) -> void:
	if(takenDamage != 0):
		health -= takenDamage
		takenDamage = 0
		if(health <= 0):
			doDie()

func doDie():
	return
