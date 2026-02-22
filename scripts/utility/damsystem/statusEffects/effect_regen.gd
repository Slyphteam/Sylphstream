class_name STATUSREGEN extends STATUSEFFECT
# put some base values in there
@export var theDuration = randi_range(10,15) * 30
@export var healPer = 1
@export var healWindow = 30


func begin_Effect():
	doStack = true
	effectName = "Regeneration"
	effectDesc = "Will heal a total of" + str((healWindow * healPer) / theDuration) + "health"
	duration = theDuration
	applyWindow = healWindow #pipe the class-specific variable in there
	applyCountdown = applyWindow

func apply_Effect():
	ourHealthHolder.give_Health(healPer)
