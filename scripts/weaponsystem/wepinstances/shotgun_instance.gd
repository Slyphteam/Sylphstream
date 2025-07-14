##The corresponding weapon script class for the FIREARM_INFO data resource
class_name SHOTGUNINSTANCE extends GUNBASICINSTANCE

var pellets: int

##
func load_Weapon(wepToLoad:WEAP_INFO):
	super.load_Weapon(wepToLoad)
	
		#Shotgun specific variables
	doVolley = wepToLoad.shotgunMode
	pellets = wepToLoad.pelletAMT
	
	

##Run state checks per frame and update the UI
func manualProcess(delta):
	delta *= 60 #scale delta to be approx 1 frame
	#if(offCooldown):
		#if(check_Shoot_Conditions()):
			#pass
	
	#old logical block
	if(offCooldown): #we CAN shoot
		if(triggerDepressed): #and we ARE shooting
			if(reloading):
				reloading = false #stop reloading
				triggerDepressed = false
			else:
				try_Shoot() #take the shot.
			
	else: #we CAN'T shoot. Do other things!
		if(currentCooldown >= 1):
			currentCooldown -= delta
		else: 
			offCooldown = true
			currentCooldown = shotCooldown
	
	calc_Recoil(delta) #Do per-frame recoil calculations
	
	if(affectUI):
		update_UI()


##Checks eligibility to shoot and takes the shot if eligible
func try_Shoot():
	if(capacity > 0 && not reloading):
		
		#apply aimcone recoil. Calculations are done in calc_Recoil, called by manualProcess
		recoilDebt += recoilAmount 
		do_Shoot() #actually shoot the bullet, vollleyfire is handled in function
		
		
	else:
		print("click!")
	
	#no matter what, counts as a "shot"
	totalShots+=1
	
	#reset cooldown here since we run try_shoot if the trigger is depressed on a cooldown timer
	offCooldown = false 
	currentCooldown = shotCooldown

func do_Shoot():
	
	
	if(capacity <= pitchWarningAmount): #if we're low, apply a pitchwarning
		var pitchStep = 0.3 - ((0.3 / pitchWarningAmount) * capacity) + 0.05
		gunshotPlayer.pitch_scale = 1 - pitchStep
	else:
		gunshotPlayer.pitch_scale = 1 + randf_range(-0.05, 0.05) #otherwise, just enough variance to not be annoying
	
	gunshotPlayer.play()
	
	#Consume bullet
	capacity-=1 
	if(affectUI):
		uiInfo.ammoCounter.updateMag(capacity)
	
	#Actually make the raycasts and such
	for x in range(pellets):
		var space:PhysicsDirectSpaceState3D = invManager.get_space_state()
		var orig = invManager.get_Origin()
		
		maxAzimuth = currentRecoil / 7
		var randAzimuth = randf_range(0 - maxAzimuth, maxAzimuth)
		var randRoll = randi_range(0, 360)
		
		var end:Vector3 = invManager.get_End(orig, randAzimuth, randRoll)
		
		var raycheck = PhysicsRayQueryParameters3D.create(orig, end)
		raycheck.collide_with_bodies = true
		var castResult = space.intersect_ray(raycheck)
		
		if(castResult):
			var hitObject = castResult.get("collider")
			if(hitObject.is_in_group("damage_interactible")):
				var alteredDamage = damage
				alteredDamage += randi_range(-3, 3)
				hitObject.hit_By_Bullet(alteredDamage,2,3,4)
			if(hitObject.is_in_group("does_hit_decals")):
				do_Hit_Decal(castResult.get("position"))
		
	
	#finally, apply camera recoil. Aimkickbonus is always half of kick amount.
	var lift = randi_range((aimKickBonus/2)+1, kickAmount) * punchMult
	var drift = randi_range((0 - aimKickBonus), aimKickBonus) * punchMult
	invManager.applyViewpunch(drift, lift)

func do_Hit_Decal(pos):
	var managerTree = invManager.get_tree()
	var hitdecalscene = preload("res://scenes/trivial/bullet_decal.tscn")
	var decalInstance = hitdecalscene.instantiate()
	managerTree.root.add_child(decalInstance)
	decalInstance.global_position = pos
	decalInstance.rotation = invManager.get_Rotation()
	
	decalInstance.rotation.z = randi_range(-2, 2)
	await managerTree.create_timer(10).timeout
	decalInstance.queue_free()

##ADS is disabled for shotguns. Is this super accurate? not really. but it  avoids jank.
func toggleADS():
	return

##Starts reload timer
func startReload():
	#print("Starting new cycle!")
	reloading = true
	
	#Should we have capacity being >= max here? Double check at some point
	if(triggerDepressed || capacity > maxCapacity+1 || invManager.getAmmoAmt(chambering)<1): #No reason to reload
		#print("exiting")
		reloading = false
		return
	
	#doing per-shell reloading here
	#var curReloadTime = reloadTime * (maxCapacity - capacity) #Scale reload time with how many new shells
	#moved gunshot player elsewhere so it plays AS the shell is inserted
	reloading = true
	await invManager.get_tree().create_timer(reloadTime).timeout
	reload_Complete()
	

func reload_Complete() -> void:
	if(!reloading):
		return
	
	#print("Cycle finished")
	#var takenAmount = (maxCapacity - capacity)
	#always attempt to +1 the shotgun, so skip on this logic
	#if(capacity > 0):
		#takenAmount+=1 #we have 1 in the chamber, so add a bonus round

	var shell = invManager.withdrawAmmo(chambering, 1)
	
	capacity += shell
	
		#however, we'll still need to update the counter
	if(affectUI):
		uiInfo.ammoCounter.updateMag(capacity)
	
	reloadPlayer.play() #play AS we insert the round, not before
	#print("Finished reload! Rounds: ", capacity)
	if(capacity <= maxCapacity):
		startReload()
