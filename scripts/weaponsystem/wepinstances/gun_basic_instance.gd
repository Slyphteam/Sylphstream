##The corresponding weapon script class for the FIREARM_INFO data resource
class_name GUNBASICINSTANCE extends WEPINSTANCE

#References
var weaponMesh: MeshInstance3D
var uiInfo ##Single node containing references for all the player's UI stuff, for ease of updating
var gunshotPlayer: AudioStreamPlayer3D 
var reloadPlayer: AudioStreamPlayer3D
var reloadTimer: Timer
var invManager: INVENMANAGER ##Assigned by the actual manager prior to weapon resource loading
var wepName: String

#State variables
var currentCooldown : float = 0
var affectUI = false ##Should only be true for the player's current weapon instance
var offCooldown = true ##Used to track whether or not the gun is on COOLDOWN, nothing else 
var triggerDepressed = false
var aimDownsight = false
var totalShots = 0 ##TOTAL number of ATTEMPTED shots taken in lifetime
var shotCooldown: int = 0

#Variables we track and calculate with
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

#Variables inferred from the resource
var minRecoil 
var maxRecoil
var damage : int
var chambering : int
var maxCapacity : int
var totalMaxRecoil 
var totalMinRecoil
var recoveryAmount ##How quickly do we get a hold of the gun?
var recoilAmount ##Applied per shot
var punchMult ##Multiplier to viewpunch 
var aimbonus ##Bonus to ADS accuracy/handling
var maxAzimuth: float ##abstract units divided by 7 to get degrees. why seven? dunno. screenspace reasons.
var reloadTime: float
var doVolley: bool

#Misc variables
@export var decalTimer: int = 10 ##Lifetime length, in seconds, of hitdecals

##
func load_Weapon(wepToLoad:WEAP_INFO):
	
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
	weaponMesh.scale = wepToLoad.scale
	
	gunshotPlayer = AudioStreamPlayer3D.new()
	invManager.add_child(gunshotPlayer)
	reloadPlayer = AudioStreamPlayer3D.new()
	invManager.add_child(reloadPlayer)
	
	#For now just adds a new timer to the scene tree rather than reusing one
	#reloadTimer = Timer.new()
	#reloadTimer.one_shot = true
	#reloadTimer.autostart = false
	#invManager.add_child(reloadTimer)
	
	
	#var decalInstance = hitdecalscene.instantiate()
	#get_tree().root.add_child(decalInstance)
	#
	#
	
	
		#grab all our variables
	shotCooldown = wepToLoad.shotCooldown
	
	maxCapacity = wepToLoad.maxCapacity
	chambering = wepToLoad.chambering
	minRecoil = wepToLoad.minRecoil
	maxRecoil = wepToLoad.maxRecoil
	recoveryAmount = wepToLoad.recoverAmount
	recoilAmount = wepToLoad.recoilAmount
	punchMult = wepToLoad.viewpunchMult
	maxAzimuth = currentRecoil / 7
	reloadTime = wepToLoad.reloadtime
	aimbonus = wepToLoad.aimBonus
	
	
	gunshotPlayer.stream = wepToLoad.gunshot
	reloadPlayer.stream = wepToLoad.reload
	

	
	#initialize stats
	capacity = maxCapacity
	reloading = false
	totalMinRecoil = minRecoil
	totalMaxRecoil = maxRecoil
	
	currentRecoil = minRecoil 
	recoveryCutoff = maxRecoil / 3
	recoveryDivisor = maxRecoil * 2 * (1+recoveryAmount)
	#include aimbonus and recovery speed in calculating. Essentially, the "ergonomics"
	#recoil amount (reduced)              #negative penalty for low recovery
	kickAmount = (recoilAmount / 4) + ((5 / ((10 * recoveryAmount))+1) ) - 3
	@warning_ignore("integer_division") aimKickBonus = (kickAmount / 2) 
	
	if(capacity < 2):
		pitchWarningAmount = -1 #don't bother
	elif(capacity <= 10):
		@warning_ignore("integer_division") pitchWarningAmount = maxCapacity / 2 #do bother but only on half 
	else:
		@warning_ignore("integer_division") pitchWarningAmount = maxCapacity / 3
	
	
	if(kickAmount <=0):
		kickAmount = 1
		aimKickBonus = 0
	
	#if(affectUI):
		#update_UI()

func give_Player_UI(newUiInfo):
	
	affectUI = true
	uiInfo = newUiInfo
	print("Loading ", wepName)
	
	return



##Run state checks per frame and update the UI
func manualProcess(delta):
	delta *= 60 #scale delta to be approx 1 frame
	#old logical block
	if(offCooldown): #we CAN shoot
		if(triggerDepressed): #and we ARE shooting
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
		do_Shoot() #actually shoot the bullet
		
		if(doVolley): #and a few more for good measure
			for x in range(11):
				do_Shoot()
	
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
	
	#Update the current magazine capacity
	if(affectUI):
		uiInfo.ammoCounter.updateMag(capacity)
	
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


func toggleADS():
	if(aimDownsight):
		kickAmount += aimKickBonus
		adjustAcuracy(aimbonus)
		aimDownsight = false
		#print("unaiming. recovery speed: ", recoveryAmount, "  kick amount: ", kickAmount)
	else:
		kickAmount -= aimKickBonus
		adjustAcuracy(0 - aimbonus)
		aimDownsight = true
		#print("aiming. recovery speed: ", recoveryAmount, "  kick amount: ", kickAmount)

##Updates the max/min aimcone by a given value. Can be negative.
func adjustAcuracy(amnt):
	
	#I REALLY don't trust float imprecision here
	recoveryAmount -= amnt / 10 #buff recovery speed by a fraction of the penalty amount
	
	if(amnt > 0): #if we're growing reticle, apply the debt. Otherwise let the reticle shrink.
		recoilDebt+=amnt
	
	#somewhat misleading but the absolute smallest value that max can be and still preserve their delta
	var absoluteMin = totalMaxRecoil - totalMinRecoil

	minRecoil = clamp(minRecoil+amnt, 0, 200) 
	maxRecoil = clamp(maxRecoil+amnt, absoluteMin, 200)
	
	recoveryDivisor = maxRecoil * 2 * (1 + recoveryAmount) #recalculate recoverydivisor
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
			var amnt = sqrt(currentRecoil / recoveryDivisor) 
			currentRecoil-= amnt * delta
	
	if(currentRecoil > 120): #provide a hard maximum ceiling for recoil that is ridiculously high.
		currentRecoil = 120

##Starts reload timer
func startReload():
	
	if(reloading || (capacity >= maxCapacity + 1)): #No reason to reload
		return
	
	
	reloadPlayer.play()
	#print("Starting reload!")
	reloading = true
	#reloadTimer.start();
	
	#In theory, this is bad code, but in case I ever want to revert back to
	#using the reloadtimer rather than making a new one, I'm leaving it in.
	await invManager.get_tree().create_timer(reloadTime).timeout
	reload_Complete()
	

func reload_Complete() -> void:
	reloading = false
	var takenAmount = (maxCapacity - capacity)
	
	if(capacity > 0):
		takenAmount+=1 #we have 1 in the chamber, so add a bonus round

	#Withdraw ammo. This will update the reserve counter on the UI automatically
	var newCap = invManager.withdrawAmmo(chambering, takenAmount)
	
	capacity += newCap
	
	#however, we'll still need to update the counter
	if(affectUI):
		uiInfo.ammoCounter.updateMag(capacity)
	#print("Finished reload! Rounds: ", capacity)


##Updates UI. Called every frame so there's no need to call it anywhere else.
func update_UI():
	uiInfo.theReticle.adjust_spread(currentRecoil)
	
func unload():
	weaponMesh.queue_free()
	gunshotPlayer.queue_free()
	reloadPlayer.queue_free()
	#reloadTimer.queue_free()
