##The generic healthholder script, just keeps track of a value. The parent object MUST implement doDie()
class_name HEALTHHOLDER extends Node
#worth doing: think about changing this to not update on process.
#This will mean you can't have "batch" damage (i.e. grouped shotgun hits)
#but it will make it simpler and cheaper codewise
func _init():
	health = startingHP
@onready var ourParent = $".."
@export var maxHP = 100
@export var startingHP = 100
var health: int = 1
var takenDamage: int = 0 ##What's the damage we're applying to health for the frame?

##Basic access function that gives the current health
func check_HP()->int:
	return health

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
	ourParent.doDie()
