class_name STATUSPLACEBO extends STATUSEFFECT


func processEffect(delta):
	super.processEffect(delta)
#	print(applyCountdown)

func applyEffect():
	#print("applying effect!")
	ourHealthHolder.give_Health(1)

func beginEffect():
	print("beginning!")
	duration = randi_range(30, 200)
	applyWindow = 50
	applyCountdown = applyWindow
