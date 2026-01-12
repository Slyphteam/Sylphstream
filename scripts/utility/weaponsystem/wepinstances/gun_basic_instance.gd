##The corresponding weapon script class for the FIREARM_INFO data resource
class_name GUNBASICINSTANCE extends WEPINSTANCE

#References

var gunshotPlayer: AudioStreamPlayer3D 
var reloadPlayer: AudioStreamPlayer3D
var reloadTimer: Timer

var wepName: String

#State variables
var currentCooldown : float = 0
var offCooldown = true ##Used to track whether or not the gun is on COOLDOWN, nothing else 
var triggerDepressed = false
var aimDownsight = false
var totalShots = 0 ##TOTAL number of ATTEMPTED shots taken in lifetime. IIRC used in sylph training.
var shotCooldown: int = 0

#Variables we track and calculate with (A.K.A state variables 2 electric boogaloo)
var capacity : int
var reloading : bool
var currentRecoil: float = 0 ##The current "amount" of recoil, in abstract units
var recoilDebt = 0 ##lets recoil be applied across multiple frames
var debtCutoff = 10 ##at what point do we just apply the recoil debt flat out?
var recoveryCutoff ##at what point do we increase our recoil recovery?
var recoveryDivisor ##Used in recoil recovery computation
var kickAmount: int ##Used in randomly generating recoil viewpunch
var aimKickBonus ##Used because we don't like integer division around these parts
var pitchWarningAmount ##used to determine when the pitch change starts and how many increments there are

var ourWeaponSheet: WEAP_INFO ##Datasheet for weapon constants

#Variables inferred from the resource
var minRecoil 
var maxRecoil
var totalMaxRecoil 
var totalMinRecoil
var speedlessMinRecoil ##Min recoil, before speed mod is applied. Think of this as the behavior if speed penalties were disabled.
var speedlessMaxRecoil ##Max recoil, before speed mod is applied. Think of this as the behavior if speed penalties were disabled.
var recoveryAmount ##How quickly does recoil go away?

var casingPath:String

var reloadTime: float

#Misc variables
#@export var decalTimer: int = 10 ##Lifetime length, in seconds, of hitdecals

##
func load_Weapon(wepToLoad:WEAP_INFO):
	super(wepToLoad) #this just grabs the datasheet and nothing else
	
	wepName = wepToLoad.wepName
	
	if(!wepToLoad is FIREARM_INFO):
		print("Tried to load non-firearm info resource as a firearm! Bad! USE THE RIGHT CLASS!")
		return
	
	#Instantiate other components we'll need to function
	weaponMesh = MeshInstance3D.new()
	invManager.add_child(weaponMesh)
	weaponMesh.mesh = wepToLoad.mesh
	weaponMesh.position = wepToLoad.position
	weaponMesh.rotation_degrees = wepToLoad.rotation
	#weaponMesh.scale = wepToLoad.scale
	
	gunshotPlayer = AudioStreamPlayer3D.new()
	invManager.add_child(gunshotPlayer)
	reloadPlayer = AudioStreamPlayer3D.new()
	invManager.add_child(reloadPlayer)
	
	
	ourWeaponSheet = wepToLoad ##assign our sheet
	
	
	#For now just adds a new timer to the scene tree rather than reusing one
	#reloadTimer = Timer.new()
	#reloadTimer.one_shot = true
	#reloadTimer.autostart = false
	#invManager.add_child(reloadTimer)
	
	#Decals have been moved to shotbullet or whatever its called
	#var decalInstance = hitdecalscene.instantiate()
	#get_tree().root.add_child(decalInstance)

		#grab all our variables
	shotCooldown = wepToLoad.shotCooldown
	
	minRecoil = wepToLoad.minRecoil
	maxRecoil = wepToLoad.maxRecoil
	recoveryAmount = wepToLoad.recoverAmount
	reloadTime = wepToLoad.reloadtime
	
	gunshotPlayer.stream = wepToLoad.gunshot
	reloadPlayer.stream = wepToLoad.reload
	

	casingPath = wepToLoad.casingPath
	
	#initialize stats
	capacity = wepToLoad.maxCapacity
	reloading = false
	
	speedlessMaxRecoil = maxRecoil
	speedlessMinRecoil = minRecoil
	totalMinRecoil = minRecoil
	totalMaxRecoil = maxRecoil
	
	currentRecoil = minRecoil 
	recoveryCutoff = maxRecoil / 3
	recoveryDivisor = maxRecoil * 2 * (1 + (1/recoveryAmount))
	#include aimbonus and recovery speed in calculating. Essentially, the "ergonomics"
	#recoil amount (reduced)              #negative penalty for low recovery
	kickAmount = (wepToLoad.recoilAmount / 4) + ((5 / ((10 * recoveryAmount))+1) ) - 3
	@warning_ignore("integer_division") aimKickBonus = (kickAmount / 2) 
	
	if(capacity < 2):
		pitchWarningAmount = -1 #don't bother
	elif(capacity <= 10):
		@warning_ignore("integer_division") pitchWarningAmount = wepToLoad.maxCapacity / 2 #do bother but only on half 
	else:
		@warning_ignore("integer_division") pitchWarningAmount = wepToLoad.maxCapacity / 3
	
	
	if(kickAmount <=0):
		kickAmount = 1
		aimKickBonus = 0
	

##Run state checks per frame and update the UI
func manualProcess(delta):
	delta *= 60 #scale delta to be approx 1 frame
	#old logical block
	if(offCooldown): #we CAN shoot
		if(triggerDepressed): #and we ARE shooting
			if(reloading && ourWeaponSheet.singleReloadOverride): 
				reloading = false #if we're a shotgun-style reloader, exit reload loop early
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
		recoilDebt += ourWeaponSheet.recoilAmount 
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
	
	
	var maxAzimuth: float = currentRecoil / 7  ##abstract units divided by 7 to get degrees. why seven? dunno. screenspace reasons.
	var randAzimuth = randf_range(0 - maxAzimuth, maxAzimuth)
	var randRoll = randi_range(0, 360)
	
	var space:PhysicsDirectSpaceState3D = invManager.get_space_state()
	var orig = invManager.get_Origin()
	var end:Vector3 = invManager.get_End(orig, randAzimuth, randRoll)
	
	#This function "actually shoots the bullet" but we only ACTUALLY "shoot" the bullet here.
	for x in range(ourWeaponSheet.pelletAMT):
		
		var theDamage = randi_range(ourWeaponSheet.damage - ourWeaponSheet.bulletVariance, ourWeaponSheet.damage + ourWeaponSheet.bulletVariance)
		var theDamInfo = DAMINFO.new()
		theDamInfo.assign_Info(theDamage, 0, invManager.user, (end-orig).normalized())
		
		var theShot = FIREDBULLET.new() 
		theShot.assign_Info(orig, end, space, theDamInfo)
		theShot.take_Shot()
		
		randAzimuth = randf_range(0 - maxAzimuth, maxAzimuth)
		randRoll = randi_range(0, 360)
		end = invManager.get_End(orig, randAzimuth, randRoll)
		
	
	#Update the current magazine capacity
	if(affectUI):
		uiInfo.updateMag(capacity)
	
	#finally, apply camera recoil. Aimkickbonus is always half of kick amount.
	var lift = randi_range((aimKickBonus/2)+1, kickAmount) * ourWeaponSheet.viewpunchMult
	var drift = randi_range((0 - aimKickBonus), aimKickBonus) * ourWeaponSheet.viewpunchMult
	invManager.applyViewpunch(drift, lift)
	
	if(ourWeaponSheet.doCasing && !ourWeaponSheet.ejectOnReload):
		if(ourWeaponSheet.casingDelay !=0):
			await Globalscript.theTree.create_timer(ourWeaponSheet.casingDelay).timeout #probably a lot of overhhead here?
		eject_Casing()


func toggleADS():
	if(aimDownsight):
		kickAmount += aimKickBonus
		
		#check and ensure we're not carrying any speed modifiers into our calculations
		if(speedlessMaxRecoil != maxRecoil): #discrepancy between speed modifier and true size
			maxRecoil = speedlessMaxRecoil #disregard applied modifiers
		if(speedlessMinRecoil != minRecoil): #same for min speed, but we want to begin "aimed"
			minRecoil = speedlessMinRecoil - ourWeaponSheet.aimBonus
		
		
		adjustAcuracy(ourWeaponSheet.aimBonus)
		speedlessMaxRecoil = maxRecoil
		speedlessMinRecoil = minRecoil
		aimDownsight = false
		#print("unaiming. recovery speed: ", recoveryAmount, "  kick amount: ", kickAmount, " Minrecoil: ", minRecoil)
	else:
		kickAmount -= aimKickBonus
		
		adjustAcuracy(0 - ourWeaponSheet.aimBonus)

		aimDownsight = true
		#print("aiming. recovery speed: ", recoveryAmount, "  kick amount: ", kickAmount, " Minrecoil: ", minRecoil)

var didPenalty = false

#right now this is ONLY based off the player running/crouching/standing.
func do_Move_Penalty(speed):
	
	var speedCalib #the speed, offset by the "start" at which we're applying penalties from
	
	 
	
	#if we're ADS and moving at ALL, apply penalty.
	if(aimDownsight):
		
		#speed calib = speed
		speedCalib = speed - 4
		if(speedCalib > 0): #check for our threshhold
			didPenalty = true #it's time to ACTIVATE!
			doFrameAccuracy(speedCalib)
		
	
	#otherwise, check for sprinting speed
	

##changes the accuracy of the weapon at a given frame. Differs from adjustAcuracy in that it is meant to be called per frame.
func doFrameAccuracy(amnt):
	pass
	#minrecoil is speedless plus amount
	#maxrecoil is speedless plus amount
	#I think that's all there is to it

##Updates the max/min aimcone by a given value. Use negative to shrink size.
func adjustAcuracy(amnt):
	
	#I REALLY don't trust float imprecision here
	recoveryAmount -= amnt / 5 #buff recovery speed by a fraction of the penalty amount
	
	if(amnt > 0): #if we're growing reticle, apply the debt. Otherwise let the reticle shrink.
		recoilDebt+=amnt
	
	#somewhat misleading but the absolute smallest value that max can be and still preserve their delta
	var absoluteMin = totalMaxRecoil - totalMinRecoil
	
	#never EVER go above 11 degrees of recoil (an absurd amount)
	minRecoil = clamp(minRecoil+amnt, 0, 80) 
	maxRecoil = clamp(maxRecoil+amnt, absoluteMin, 80)
	

	recoveryDivisor = maxRecoil * 2 * (1 + (1/recoveryAmount)) #recalculate recoverydivisor
	recoveryCutoff = maxRecoil / 3
	
	#calc_Recoil() already updating recoil on a per-frame basis.


##Apply any recoil "debt" accumulated and calculate recovery, DOES NOT UPDATE UI
func calc_Recoil(delta):
	#print(delta)
	if(recoilDebt == 0 && currentRecoil <= minRecoil): #don't bother
		return
	
	#apply recoil debt. Ensures that guns with high recoil don't feel unpleasantly snappy
	if(recoilDebt > 0):
		if(recoilDebt < debtCutoff): #debtcutoff is a constant equal to 10
			currentRecoil += (recoilDebt * delta) #add ALL the rest of the debt and set to 0
			recoilDebt = 0
		else:
			var exchange = 0.5 * recoilDebt * delta
			currentRecoil += exchange
			recoilDebt -= exchange
		
		#still don't exceed the maximum
		if(currentRecoil > maxRecoil):
			currentRecoil = maxRecoil
	
	#calculate recovery
	#recoverycutoff is the point at which we switch from linear to square root recovery amount
	#recoverydivisor is calculated above and slightly complex but behaves like a constant
	if(currentRecoil > minRecoil):
		if(currentRecoil <= recoveryCutoff): #1/4th of maxrecoil
			currentRecoil -= recoveryAmount * delta
			if(currentRecoil < minRecoil):
				currentRecoil = minRecoil
		else:
			var amnt = sqrt(currentRecoil / recoveryDivisor) + (delta / 10) #take sqrt, but keep some linearity
			currentRecoil-= amnt * delta
	
	if(currentRecoil > 120): #provide a hard maximum ceiling for recoil that is ridiculously high.
		currentRecoil = 120

##Starts reload timer 
func startReload():
	
	#No reason to or can't reload
	if((capacity >= ourWeaponSheet.maxCapacity + 1) || (invManager.chkAmmoAmt(ourWeaponSheet.chambering) == 0)): 
		#single/multi reloads have slightly different early cancel logic
		if((ourWeaponSheet.singleReloadOverride && triggerDepressed) || (!ourWeaponSheet.singleReloadOverride && reloading)):
			reloading = false
			return
	
	reloading = true
	
	if(!ourWeaponSheet.singleReloadOverride): #single reloads play the sound AFTER the reload completes
		reloadPlayer.play()
	#print("Starting reload!")
		
	#reloadTimer.start();
	
	#In theory, this is bad code, but in case I ever want to revert back to
	#using the reloadtimer rather than making a new one, I'm leaving it in.
	await invManager.get_tree().create_timer(reloadTime).timeout
	reload_Complete()
	

func reload_Complete() -> void:
	if(!reloading):
		return
	
	#fairly differing behaviors for single/multi reload
	if(!ourWeaponSheet.singleReloadOverride):
		reloading = false
		var takenAmount = (ourWeaponSheet.maxCapacity - capacity)
		if(capacity > 0):
			takenAmount+=1 #we have 1 in the chamber, so add a bonus round
		#Withdraw ammo. This will update the reserve counter on the UI automatically
		var newCap = invManager.withdrawAmmo(ourWeaponSheet.chambering, takenAmount)
		capacity += newCap
	
	else:
		var shell = invManager.withdrawAmmo(ourWeaponSheet.chambering, 1)
		capacity += shell
		reloadPlayer.play()
		if(capacity <= ourWeaponSheet.maxCapacity):
			startReload()
		else:
			reloading = false
		
		
	if(affectUI):
			uiInfo.updateMag(capacity)
	
	#however, we'll still need to update the counter
	
	#print("Finished reload! Rounds: ", capacity)

func eject_Casing():
	
	if(!casingPath || !ourWeaponSheet.doCasing): #this shouldnt happen but lets not crash the program
		print("weapinstance eject_Casing had invalid call, fix your stuff!!")
		return
	
	#print(casingPath)
	#var testyScene = 
	var newCasing = load(casingPath).instantiate()
	#ResourceLoader.load(casingPath).instantiate()
	
	
	newCasing.position = weaponMesh.global_position
	newCasing.rotation = invManager.get_Rotation() + Vector3(0, 3.14, 0)
	newCasing.linear_velocity = invManager.get_Speed()
	
	#Add a "kick" to the ejected casing
	var casingVel = (Vector3(3, 2, 0) * ourWeaponSheet.casingSpeedBoost) 
	casingVel += Vector3(randi_range(-1, 1), randi_range(-0.5, 0.5), randi_range(-0.5, 0.5))
	newCasing.linear_velocity += casingVel.rotated(Vector3.UP, invManager.get_Rotation().y) #ensure it's perpindicular to ourselves
	
	#some forwards/back spin, a LOT of lateral spin
	var angVel = Vector3(randi_range(-10, 10), randi_range(-20, 20), 0)
	
	newCasing.apply_torque(angVel)
	
	Globalscript.theTree.root.add_child(newCasing)
	Globalscript.push_Casing(newCasing, affectUI)
	

##Updates UI. Called every frame so there's no need to call it anywhere else.
func update_UI():
	uiInfo.adjust_spread(currentRecoil)

##Does some extra cleanup on the instance
func unload():
	weaponMesh.queue_free()
	gunshotPlayer.queue_free()
	reloadPlayer.queue_free()
	#reloadTimer.queue_free()

func getGunMesh():
	return weaponMesh
