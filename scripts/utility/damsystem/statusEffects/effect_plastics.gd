class_name STATUSMICROPLASTIC extends STATUSEFFECT
@export var healthPenalty = 16

func begin_Effect():
	effectName = "Full of Microplastics"
	effectDesc = "The microplastics inside your body have taken a toll on your health! Maximum HP has temporarily reduced."
	healthPenalty = randi_range(7,14)
	duration = randi_range(450, 850)
	#print("health penalty: ", healthPenalty)
	doStack = false
	
	ourHealthHolder.maxHP -= healthPenalty
	
	#var takenDam = (ourHealthHolder.maxHP - ourHealthHolder.health) 
	#
	#if(healthPenalty > takenDam): #if we're decreasing lower than the current max hp, apply damage
		#ourHealthHolder.take_TrueDam(healthPenalty - takenDam)
	
	#print("new health ", ourHealthHolder.health)


func expire_Effect():
	ourHealthHolder.maxHP += healthPenalty
