# this is THE script that drives weapon behavior and loads weapon models/stats
#into a game instance. It answers directly to the invenmanager script.

extends Node3D

@export var Starting_Wep: WEAPON_PARENT
@onready var weapon_mesh: MeshInstance3D = $weapModel
@onready var our_reticle: CenterContainer 
@onready var gunshotPlayer: AudioStreamPlayer3D = $gunshotPlayer
@onready var reloadPlayer: AudioStreamPlayer3D = $reloadPlayer




#Resource loading code:
#func _ready() -> void:
	
	#



func load_weapon(weaponToLoad:WEAPON_PARENT, reticle):
	#print("Loading weapon mesh: ", weaponToLoad.mesh)
	weapon_mesh.mesh = weaponToLoad.mesh
	
	position = weaponToLoad.position
	rotation_degrees = weaponToLoad.rotation
	scale = weaponToLoad.scale
	damage = weaponToLoad.damage
	isFirearm = weaponToLoad.isFirearm
	
	if(reticle):
		affectUI = reticle
		our_reticle = $"../../../../Control/Reticle"
	
	if(isFirearm):
		init_Firearm_Stats(weaponToLoad)


#weapon behavior code
@onready var reloadtimer = $reloadTimer
@onready var manager: INVENMANAGER = $".."
#Variables we calculate with


var damage : int
var currentCooldown : int = 0
var isFirearm : bool
var affectUI = false
var canShoot = true
var triggerDepressed = false
var totalShots = 0 ##TOTAL number of shots taken in lifetime

var capacity : int
var reloading : bool
var currentRecoil: float = 0 ##The current "amount" of recoil, in abstract units
var minRecoil
var maxRecoil
var recoilDebt = 0 ##lets very heavy recoil be applied across multiple frames

#variables inferred from the resource
var shotCooldown: int = 0
var chambering : int
var maxCapacity : int
var totalMaxRecoil
var totalMinRecoil
var recoveryAmount
var recoilAmount
var aimbonus
var maxAzimuth: float #recoil units divided by 7 to get degrees. why seven? dunno. screenspace reasons.

var modeSemi


var debtCutoff = 10 ##at what point do we just apply the recoil debt flat out?
var recoveryCutoff ##at what point do we increase our recoil recovery?
var recoveryDivisor ##Used in recoil recovery computation
var kickAmount: int ##Used in randomly generating recoil viewpunch
var aimKickBonus ##Used because we don't like integer division around these parts




func init_Firearm_Stats(weaponToLoad):
	#grab all our variables
	shotCooldown = weaponToLoad.shotCooldown
	
	maxCapacity = weaponToLoad.maxCapacity
	chambering = weaponToLoad.chambering
	totalMinRecoil = weaponToLoad.minRecoil
	totalMaxRecoil = weaponToLoad.maxRecoil
	recoveryAmount = weaponToLoad.recoverAmount
	recoilAmount = weaponToLoad.recoilAmount
	maxAzimuth = currentRecoil / 7
	reloadtimer.wait_time = weaponToLoad.reloadtime
	aimbonus = weaponToLoad.aimBonus
	
	gunshotPlayer.stream = weaponToLoad.gunshot
	reloadPlayer.stream = weaponToLoad.reload
	
	modeSemi = weaponToLoad.modeSemi
	
	
	
	#initialize stats
	capacity = maxCapacity
	reloading = false
	maxRecoil = totalMaxRecoil
	minRecoil = totalMinRecoil
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
	
	if(affectUI):
		our_reticle.adjust_spread(minRecoil)
		
	


func tryShoot():
	if(capacity > 0 && not reloading):
		
		#Consume bullet
		capacity-=1
		
		#apply aimcone recoil. Calculations are elsewhere
		recoilDebt += recoilAmount 
		makeGunshot()
		
		doShoot() #actually shoot the bullet
		
		#afterwards, apply camera recoil. Aimkickbonus is always half of kick amount.
		var lift = randi_range((aimKickBonus/2)+1, kickAmount)
		var drift = randi_range((0 - aimKickBonus), aimKickBonus)
		manager.applyViewpunch(drift, lift)
		
		#print("Pew! Recoil: ", int(currentRecoil), " Kick: ", lift, ";", drift)
		
	else:
		print("click!")
		totalShots+=1



func makeGunshot():
	gunshotPlayer.pitch_scale = 1 + randf_range(-0.05, 0.05)
	gunshotPlayer.play()


##This function will always fire a bullet from the center of the screen
func doShoot():
		var space:PhysicsDirectSpaceState3D = manager.get_space_state()
		var orig = manager.get_Origin()
		
		
		maxAzimuth = currentRecoil / 7
		var randAzimuth = randf_range(0 - maxAzimuth, maxAzimuth)
		var randRoll = randi_range(0, 360)
		
		var end:Vector3 = manager.get_End(orig, randAzimuth, randRoll)
		
		var raycheck = PhysicsRayQueryParameters3D.create(orig, end)
		raycheck.collide_with_bodies = true
		var castResult = space.intersect_ray(raycheck)
		
		if(castResult):
			var hitObject = castResult.get("collider")
			if(hitObject.is_in_group("damage_interactible")):
				doBulletInteract(hitObject)
			if(hitObject.is_in_group("does_hit_decals")):
				doHitDecal(castResult.get("position"))
				

@export var decalTimer: int = 10
#var decals = 0
var hitdecalscene = preload("res://scenes/trivial/bullet_decal.tscn")
func doHitDecal(pos):
	var decalInstance = hitdecalscene.instantiate()
	get_tree().root.add_child(decalInstance)
	decalInstance.global_position = pos
	decalInstance.rotation = manager.get_Rotation()
	
	decalInstance.rotation.z = randi_range(-2, 2)
	await get_tree().create_timer(10).timeout
	decalInstance.queue_free()
	

func doBulletInteract(victim):
	var alteredDamage = damage
	alteredDamage += randi_range(-3, 3)
	victim.hit_By_Bullet(alteredDamage,2,3,4)

##Starts reload timer
func startReload():
	
	if(reloading || (capacity >= maxCapacity + 1)):
		print("nuh uh")
		return
	
	
	reloadPlayer.play()
	#print("Starting reload!")
	reloading = true
	reloadtimer.start();

func _on_reload_timer_timeout() -> void:
	reloading = false
	var takenAmount = (maxCapacity - capacity)
	
	if(capacity > 0):
		takenAmount+=1 #we have 1 in the chamber, so plus 1 the weapon

	var newCap = manager.withdrawAmmo(chambering, takenAmount)
	
	capacity += newCap
	#print("Finished reload! Rounds: ", capacity)
	if(affectUI):
		Globalscript.datapanel.add_Property("Reserve ", manager.getAmmoAmt(chambering), 5)


func _process(_delta: float): 
	if(canShoot): #we CAN shoot
		if(triggerDepressed): #and we ARE shooting
			tryShoot() #take the shot.
			canShoot = false
			currentCooldown = shotCooldown
	else: #we CAN'T shoot. Do other things!
		if(currentCooldown > 0):
			currentCooldown -=1
		else: 
			canShoot = true
			currentCooldown = shotCooldown
	
	if(isFirearm && affectUI):
		Globalscript.datapanel.add_Property("Current capacity ", capacity, 3)
		Globalscript.datapanel.add_Property("Current aimcone ", int(currentRecoil), 4) #runtime here!!!
		Globalscript.datapanel.add_Property("Reserve ", manager.getAmmoAmt(chambering), 5)
		calcRecoil() 
	

##Apply any recoil "debt" accumulated and calculate recovery
func calcRecoil():
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
	
	#update the UI
	if(affectUI):
		our_reticle.adjust_spread(currentRecoil)


var aimdownsights = false
func toggleADS():
	if(aimdownsights):
		kickAmount += aimKickBonus
		adjustAcuracy(aimbonus)
		aimdownsights = false
		print("unaiming. recovery speed: ", recoveryAmount, "  kick amount: ", kickAmount)
	else:
		kickAmount -= aimKickBonus
		adjustAcuracy(0 - aimbonus)
		aimdownsights = true
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
	
	calcRecoil()
