##The corresponding weapon script class for the FIREARM_INFO data resource
class_name GUNBASICINSTANCE extends WEPINSTANCE

#References
var weaponMesh: MeshInstance3D
var ourReticle: CenterContainer 
var gunshotPlayer: AudioStreamPlayer3D 
var reloadPlayer: AudioStreamPlayer3D
var reloadTimer: Timer
var invManager: INVENMANAGER ##Assigned by the actual manager prior to weapon resource loading

#State variables
var currentCooldown : int = 0
var affectUI = false ##Should only be true for the player's current weapon instance
var canShoot = true
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

#Misc variables
@export var decalTimer: int = 10 ##Lifetime length, in seconds, of hitdecals

##
func load_Weapon(wepToLoad:WEAP_INFO, isPlayer: bool, reticle: CenterContainer ):
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
	
	if(isPlayer):
		affectUI = true
		ourReticle = reticle
		#ourReticle.adjust_spread(minRecoil)
	
	print("Loading ", wepToLoad.wepName)
	
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
	
	if(kickAmount <=0):
		kickAmount = 1
		aimKickBonus = 0
	
	#if(affectUI):
		#update_UI()


##Run state checks per frame and update the UI
func manualProcess():
	if(canShoot): #we CAN shoot
		if(triggerDepressed): #and we ARE shooting
			try_Shoot() #take the shot.
			canShoot = false
			currentCooldown = shotCooldown
	else: #we CAN'T shoot. Do other things!
		if(currentCooldown > 0):
			currentCooldown -=1
		else: 
			canShoot = true
			currentCooldown = shotCooldown
	
	calc_Recoil() #Do per-frame recoil calculations
	
	if(affectUI):
		update_UI()


##Checks eligibility to shoot
func try_Shoot():
	if(capacity > 0 && not reloading):
		
		#Consume bullet
		capacity-=1
		
		#apply aimcone recoil. Calculations are done in calc_Recoil, called by manualProcess
		recoilDebt += recoilAmount 
		
		#Make gunshot noise.
		#TODO: pitch increase when ammo gets low
		gunshotPlayer.pitch_scale = 1 + randf_range(-0.05, 0.05)
		gunshotPlayer.play()
		
		do_Shoot() #actually shoot the bullet
		
		#afterwards, apply camera recoil. Aimkickbonus is always half of kick amount.
		var lift = randi_range((aimKickBonus/2)+1, kickAmount) * punchMult
		var drift = randi_range((0 - aimKickBonus), aimKickBonus) * punchMult
		invManager.applyViewpunch(drift, lift)
		
		#print("Pew! Recoil: ", int(currentRecoil), " Kick: ", lift, ";", drift)
		
	else:
		print("click!")
	
	totalShots+=1

func do_Shoot():
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
		print("unaiming. recovery speed: ", recoveryAmount, "  kick amount: ", kickAmount)
	else:
		kickAmount -= aimKickBonus
		adjustAcuracy(0 - aimbonus)
		aimDownsight = true
		print("aiming. recovery speed: ", recoveryAmount, "  kick amount: ", kickAmount)

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
func calc_Recoil():
	if(recoilDebt == 0 && currentRecoil <= minRecoil): #don't bother
		return
	
	#apply recoil debt. Ensures that guns with high recoil don't feel unpleasantly snappy
	if(recoilDebt > 0):
		if(recoilDebt < debtCutoff): #debtcutoff is a constant equal to 10
			currentRecoil += recoilDebt #add ALL the rest of the debt and set to 0
			recoilDebt = 0
		else:
			currentRecoil += (0.5 * recoilDebt)
			recoilDebt -= (0.5 * recoilDebt)
		
		#still don't exceed the maximum
		if(currentRecoil > maxRecoil):
			currentRecoil = maxRecoil
	
	#calculate recovery
	#recoverycutoff is the point at which we switch from linear to square root recovery amount
	#recoverydivisor is calculated above and slightly complex but behaves like a constant
	if(currentRecoil > minRecoil):
		#we SHOULD be using delta here buuuuuut I don't trust float imprecision
		if(currentRecoil <= recoveryCutoff): #1/4th of maxrecoil
			currentRecoil -= recoveryAmount 
			if(currentRecoil < minRecoil):
				currentRecoil = minRecoil
		else:
			var amnt = sqrt(currentRecoil / recoveryDivisor) 
			currentRecoil-= amnt
	
	#update the UI (
	#if(affectUI):
		#ourReticle.adjust_spread(currentRecoil)

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

	var newCap = invManager.withdrawAmmo(chambering, takenAmount)
	
	capacity += newCap
	#print("Finished reload! Rounds: ", capacity)
	#if(affectUI):
		#update_UI()

##Updates UI. Called every frame so there's no need to call it anywhere else.
func update_UI():
	
	ourReticle.adjust_spread(currentRecoil)
	Globalscript.datapanel.add_Property("Current capacity ", capacity, 3)
	Globalscript.datapanel.add_Property("Current aimcone ", int(currentRecoil), 4) #runtime here!!!
	Globalscript.datapanel.add_Property("Reserve ", invManager.getAmmoAmt(chambering), 5)

func unload():
	weaponMesh.queue_free()
	gunshotPlayer.queue_free()
	reloadPlayer.queue_free()
	#reloadTimer.queue_free()
