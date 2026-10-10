class_name STATUSINSTAURA extends STATUSEFFECT
@export var healAmount:int = 25

func apply_Effect():
		ourHealthHolder.give_Health(healAmount)
		
func begin_Effect():
	doChat = false
	effectName = "Instant aura"
	effectDesc = "Instantly gives " + str(healAmount) + "aura"
	duration = 3
	ourHealthHolder.give_Aura(healAmount)
