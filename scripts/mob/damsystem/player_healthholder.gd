#Variant of a complex healthholder that updates the UI.
class_name PLAYERHEALTHHOLDER extends COMPLEXHEALTHHOLDER
@onready var healthInfo = $"Player UI/Health"

func update_True_Vals(): 
	super.update_True_Vals()
	healthInfo.updateBoth(aura, health)
	
