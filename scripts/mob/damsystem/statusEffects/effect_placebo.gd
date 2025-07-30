class_name STATUSPLACEBO extends STATUSEFFECT


func process_Effect(delta):
	super.process_Effect(delta)
#	print(applyCountdown)

func apply_Effect():
	#print("applying effect!")
	ourHealthHolder.give_Health(1)

func begin_Effect():
	effectName = "Placebo"
	effectDesc = "It might not do nothing?"
	duration = randi_range(30, 300)
	applyWindow = 100
	applyCountdown = applyWindow
