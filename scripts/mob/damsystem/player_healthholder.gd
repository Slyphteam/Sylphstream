##Variant of a complex healthholder that updates the UI.
class_name PLAYERHEALTHHOLDER extends COMPLEXHEALTHHOLDER
@onready var playerUI = $"../Player UI"

#func _ready():


func update_True_Vals(): 
	super.update_True_Vals()
	playerUI.updateHealthAura(aura, health)
	

func doDie():
	print("you are frickings dead. game oval.")
	#in the future, we'll want stuff to actually happen, but for now just reset the player
	Globalscript.thePlayer.position = Vector3(-0.2, 2, 3)
	give_Health(100 + (0 - health))


func give_Health(amount:int):
	super.give_Health(amount)
	playerUI.updateHealth(health)

func give_Health_Overmax(amount:int, newMax: int):
	super.give_Health_Overmax(amount, newMax)
	playerUI.updateHealth(health)
