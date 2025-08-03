#Variant of a complex healthholder that updates the UI.
class_name PLAYERHEALTHHOLDER extends COMPLEXHEALTHHOLDER
@onready var playerUI = $"../Player UI"
@export var startingAura: int = 10

func _ready():
	aura = startingAura

func update_True_Vals(): 
	super.update_True_Vals()
	playerUI.updateHealthAura(aura, health)
	

func doDie():
	print("you are fusksings dead. game oval.")


func give_Health(amount:int):
	super.give_Health(amount)
	playerUI.updateHealth(health)

func give_Health_Overmax(amount:int, newMax: int):
	super.give_Health_Overmax(amount, newMax)
	playerUI.updateHealth(health)
