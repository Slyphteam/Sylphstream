class_name STATUSINSTHEAL extends STATUSEFFECT
@export var healAmount:int = 10

func apply_Effect():
		ourHealthHolder.give_Health(healAmount)
		
func begin_Effect():
	effectName = "Instant heal"
	effectDesc = "Instantly gives " + str(healAmount) + "health"
	duration = 3
	ourHealthHolder.give_Health(healAmount)
