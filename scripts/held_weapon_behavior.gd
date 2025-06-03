# this is THE script that drives weapon behavior and loads weapon models/stats
#into a game instance. It answers directly to the invenmanager script.

extends Node3D

@export var WEP_TYPE: Wep
@onready var weapon_mesh: MeshInstance3D = $weapModel
@onready var our_reticle: CenterContainer = $"../../../Control/Reticle"

#Resource loading code:
func _ready() -> void:
	load_weapon()
	init_stats()



func load_weapon():
	print("Loading weapon mesh: ", WEP_TYPE.mesh)
	weapon_mesh.mesh = WEP_TYPE.mesh
	
	position = WEP_TYPE.position
	rotation_degrees = WEP_TYPE.rotation
	scale = WEP_TYPE.scale
	


#weapon behavior code
@onready var reloadtimer = $reloadTimer
@onready var manager = $".."
#Variables we calculate with
var capacity
var reloading 
var currentRecoil: float = 0
var minRecoil
var maxRecoil
var recoilDebt = 0

#variables inferred from the resource
var chambering 
var maxCapacity 
var totalMaxRecoil
var totalMinRecoil
var recoveryAmount
var recoilAmount
var aimbonus
var damage 

var debtCutoff = 10 ##at what point do we just apply the recoil debt flat out?
var recoveryCutoff ##at what point do we increase our recoil recovery?
var recoveryDivisor ##Used in recoil recovery computation
var kickAmount: int ##Used in randomly generating recoil viewpunch
var aimKickBonus ##Used because we don't like integer division around these parts

func init_stats():
	#grab all our variables
	maxCapacity = WEP_TYPE.maxCapacity
	chambering = WEP_TYPE.chambering
	totalMinRecoil = WEP_TYPE.minRecoil
	totalMaxRecoil = WEP_TYPE.maxRecoil
	recoveryAmount = WEP_TYPE.recoverAmount
	recoilAmount = WEP_TYPE.recoilAmount
	reloadtimer.wait_time = WEP_TYPE.reloadtime
	aimbonus = WEP_TYPE.aimBonus
	damage = WEP_TYPE.damage
	
	
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
	aimKickBonus = (kickAmount / 2)
	
	if(kickAmount <=0):
		kickAmount = 1
		aimKickBonus = 0
	
	
	our_reticle.adjust_spread(minRecoil)


func tryShoot():
	if(capacity > 0 && not reloading):
		
		#Consume bullet
		capacity-=1
		
		#apply aimcone recoil. Calculations are elsewhere
		recoilDebt += recoilAmount 
		
		doShoot() #actually shoot the bullet
		
		#afterwards, apply camera recoil. Aimkickbonus is always half of kick amount.
		var lift = randi_range((aimKickBonus/2)+1, kickAmount)
		var drift = randi_range((0 - aimKickBonus), aimKickBonus)
		manager.applyViewpunch(drift, lift)
		
		print("Pew! Recoil: ", int(currentRecoil), " Kick: ", lift, ";", drift)
		
	else:
		print("click!")

##This function will always fire a bullet from the center of the screen
func doShoot():
		var space = manager.get_space_state()
		var orig = manager.get_Origin()
		var end:Vector3 = manager.get_End(orig, 0, 0)
		#end.
		
		var raycheck = PhysicsRayQueryParameters3D.create(orig, end)
		raycheck.collide_with_bodies = true
		var castResult = space.intersect_ray(raycheck)
		
		if(castResult):
			var hitObject = castResult.get("collider")
			if(hitObject.is_in_group("damage_interactible")):
				doBulletInteract(hitObject)
				
		

func doBulletInteract(victim):
	victim.hit_By_Bullet(1,2,3,4)

##Starts reload timer
func startReload():
	if(!reloading):
		print("Starting reload!")
		reloading = true
		reloadtimer.start();

func _on_reload_timer_timeout() -> void:
	reloading = false
	var takenAmount = (maxCapacity - capacity)
	
	if(capacity > 0):
		takenAmount+=1 #we have 1 in the chamber, so plus 1 the weapon

	var newCap = manager.withdrawAmmo(chambering, takenAmount)
	
	capacity += newCap
	print("Finished reload! Rounds: ", capacity)
	Globalscript.datapanel.add_Property("Reserve ", manager.getAmmoAmt(chambering), 5)


func _process(delta: float): 
	
	Globalscript.datapanel.add_Property("Current capacity ", capacity, 3)
	Globalscript.datapanel.add_Property("Current aimcone ", int(currentRecoil), 4) #runtime here!!!
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
