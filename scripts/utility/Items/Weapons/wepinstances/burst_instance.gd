class_name BURSTFIREINSTANCE extends GUNBASICINSTANCE

var needsReset = false ##The user MUST release the trigger between bursts
var resetTimer : float = 10 ##Timer for reset between shots. im not adding this to the resource sheet. 
var takenShots:int = 0 ##Counter for the number of shots in the current burst
var maxShots: int ##Total number of shots per burst
var inBurst = false ##acts as a second "trigger" that terminates when maxShots is reached. user can squeeze off 1-2 without

func load_Weapon(wepToLoad:WEAP_INFO):
	super.load_Weapon(wepToLoad)
	maxShots = wepToLoad.burstAMT
	

func manualProcess(delta):
	delta *= 60 #scale delta to be approx 1 frame
	
	
	if(!offCooldown):
		currentCooldown -= delta
		if(currentCooldown <= 0):
			offCooldown = true
	
	if(triggerDepressed || inBurst): #Trigger is pressed
		if(!needsReset): #we're still in the clear as far as reset is concerned
			if(offCooldown): #we're off the intra-burst cooldown
				inBurst = true
				try_Shoot()
				offCooldown = false
				currentCooldown = shotCooldown
				takenShots += 1
				if(takenShots >= maxShots):
					needsReset = true
					inBurst = false
	else:
		if(needsReset): #trigger is released and we require a reset
			resetTimer -= delta
			if(resetTimer <= 0):
				needsReset = false
				resetTimer = 10
				takenShots = 0
	
	
	#old logical block
	#if(offCooldown): #we CAN shoot
		#if(triggerDepressed): #and we ARE shooting
			#try_Shoot() #take the shot.
			#
	#else: #we CAN'T shoot. Do other things!
		#if(currentCooldown >= 1):
			#currentCooldown -= delta
		#else: 
			#offCooldown = true
			#currentCooldown = shotCooldown

	calc_Recoil(delta) #Do per-frame recoil calculations
	
	if(affectUI):
		update_UI()
