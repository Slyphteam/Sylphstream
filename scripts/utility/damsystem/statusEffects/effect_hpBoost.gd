class_name STATUSHPBOOST extends STATUSEFFECT
@export var amount = 25

func begin_Effect():
	effectName = "Max HP boost"
	ourHealthHolder.maxHP +=amount

func expire_Effect():
	ourHealthHolder.maxHP -=amount
