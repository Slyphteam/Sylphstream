##This is the parent class for all invenmanager objects, containing boilerplate code
#Do !!NOT!! use this directly. EVER. Extend a child and override the functions going
#up the scene hierarchy, or else things won't work and also I'll come to your house
#and genuinely kill you in roblox in minecraft in fortnite in real life
class_name INVENMANAGER extends Node3D

@export var starterWeapon: INVWEP
enum Ammotypes {ammoRimfire, ammoPistol, ammoRifle, ammoThirtycal, ammoShotgun}
var heldAmmunition = {} # dictionary of all the player's held ammotypes and ammo
var reloading = false
#var heldItem: Node3D #old name for activeItem prior to the WEPINSTANCE refactor
var activeItem: WEPINSTANCE ##The current instance of the actively being used weapon
var weapType: int ##1 for basic firearm, 2 for melee...
var user : Node3D
var wepMesh: MeshInstance3D

var inAimingTransition:bool ##State variable that tells _process if we're doing any aiming
var notAimed:bool ##State variable that determines if we're ADS
var backupOffset
var didSpeedPenalty = false ##A not quite boolean variable that determines if we did a speed penalty. Incorporates a delay.
var speedPenaltyAmount = 20

func _process(delta):
	if(activeItem):
		activeItem.manualProcess(delta)
	
	
	if(inAimingTransition):
		inAimingTransition = false
		if(notAimed): 
			wepMesh.position.x = 0
		else:
			wepMesh.position.x = backupOffset

##Loads a WEPINSTANCE using universal logic.
func load_Wep(wep2Load:WEAP_INFO):
	
	if(activeItem): #unload old item
		activeItem.unload()
		activeItem.queue_free()
		activeItem = null
	
	#Decide what script is going to handle the weapon behavior
	if(wep2Load is FIREARM_INFO):
		backupOffset = wep2Load.position.x
		if(wep2Load.shotgunMode):
			activeItem = SHOTGUNINSTANCE.new()
			activeItem.invManager = self
			activeItem.load_Weapon(wep2Load)
			weapType = 1 #still use the firearm control schema
		elif(wep2Load.burstMode):
			activeItem = BURSTFIREINSTANCE.new()
			activeItem.invManager = self
			activeItem.load_Weapon(wep2Load)
			weapType = 1 #still use the firearm control schema
		else:
			activeItem = GUNBASICINSTANCE.new()
			activeItem.invManager = self
			activeItem.load_Weapon(wep2Load)
			weapType = 1 #basic gun
	elif(wep2Load is MELEE_INFO):
		activeItem = MELEEINSTANCE.new()
		activeItem.invManager = self
		activeItem.load_Weapon(wep2Load)
		weapType = 2 #Melee time
	else:
		weapType = 0 #Empty hands


#--------- ALL OF THESE FUNCTIONS EXIST INTERNALLY WITH THE INVENMANAGER
func giveAmmo(amTyp: int, amount: int):
	if (amTyp == 0):
		heldAmmunition.ammoRimfire += amount
		return heldAmmunition.ammoRimfire
	if (amTyp == 1):
		heldAmmunition.ammoPistol += amount
		return heldAmmunition.ammoPistol
	elif (amTyp == 2):
		heldAmmunition.ammoRifle += amount
		return heldAmmunition.ammoRifle
	elif (amTyp == 4): 
		heldAmmunition.ammoShotgun += amount
		return heldAmmunition.ammoShotgun
	else:
		print("Attemted to give invalid chambering!")
		return 1
	

##Decrease ammo of desired type by desired amount. Returns updated reserve.
func withdrawAmmo(amTyp: int, amount: int)-> int:
	#print("Selected type ", amTyp)
	if (amTyp == 0):
		#print("Taking ", amount, " from pool of ", heldAmmunition.ammoPistol)
		if(amount >= heldAmmunition.ammoRimfire):
			#print("making do with ", heldAmmunition.ammoPistol)
			var leftover = heldAmmunition.ammoRimfire
			heldAmmunition.ammoRimfire = 0
			return leftover
			
		heldAmmunition.ammoRimfire -= amount;
		return amount	
		#it might seem like there's a better way to do this, but I couldn't get a reference to work
	elif (amTyp == 1):
		#print("Taking ", amount, " from pool of ", heldAmmunition.ammoPistol)
		if(amount >= heldAmmunition.ammoPistol):
			#print("making do with ", heldAmmunition.ammoPistol)
			var leftover = heldAmmunition.ammoPistol
			heldAmmunition.ammoPistol = 0
			return leftover
			
		heldAmmunition.ammoPistol -= amount;
		return amount	
		#it might seem like there's a better way to do this, but I couldn't get a reference to work

	elif (amTyp == 2): 
		print("Taking ", amount, " from pool of ", heldAmmunition.ammoRifle)
		if(amount >= heldAmmunition.ammoRifle):
			print("making do with ", heldAmmunition.ammoRifle)
			var leftover = heldAmmunition.ammoRifle
			heldAmmunition.ammoRifle = 0
			return leftover
			
		heldAmmunition.ammoRifle -= amount;
		return amount
	
	elif (amTyp == 4): 
		print("Taking ", amount, " from pool of ", heldAmmunition.ammoShotgun)
		if(amount >= heldAmmunition.ammoShotgun):
			print("making do with ", heldAmmunition.ammoShotgun)
			var leftover = heldAmmunition.ammoShotgun
			heldAmmunition.ammoShotgun = 0
			return leftover
			
		heldAmmunition.ammoShotgun -= amount;
		return amount
	else:
		print("Attemted to withdraw invalid chambering!")
		return 1

##Check how much ammunition is in the reserve
func chkAmmoAmt(amTyp:int ) -> int:
	#print("requested chambering: ", amTyp)
	if(amTyp == 0):
		return heldAmmunition.ammoRimfire
	elif(amTyp == 1):
		return heldAmmunition.ammoPistol
	elif(amTyp == 2):
		return heldAmmunition.ammoRifle
	elif(amTyp == 4):
		return heldAmmunition.ammoShotgun
	else:
		print("Attempted to check invalid chambering!")
		return 0;
	#return heldAmmunition.amTyp  (mad that this doesnt work but whatever)

#--------- ALL OF THESE FUNCTIONS INTERACT WITH THE HELD ITEM (going DOWN the scene tree)


func doShoot():
	if(weapType == 1):
		activeItem.triggerDepressed = true
	elif(weapType == 2):
		activeItem.trySwing()
	else:
		pass

func unShoot():
	if(weapType == 1):
		activeItem.triggerDepressed = false
	else:
		pass
	
func startReload():
	#penalty
	if(weapType == 1):
		activeItem.startReload()
	else:
		pass

var penaltyOffset = 15 ##A value of how much we've offset the aimcone by applying the penalty. In the future, this will be dynamic.
##Apply a temporary accuracy penalty for sprinting/jumping/crouchsliding
func check_Apply_Speedpenalty(speed):
	if(weapType != 1):
		return
	
	activeItem.do_Move_Penalty(speed)
	#if(didSpeedPenalty): #if already true, check speed penalty, 
		#if(speed < 14): #return to normal
			#activeItem.adjustAcuracy(0 - penaltyOffset)
			#didSpeedPenalty = false
			#return
	#
	#else: #we haven't already
		#if(speed >= 14): #so, check, and if necessary, apply
			#activeItem.adjustAcuracy(penaltyOffset)
			#didSpeedPenalty = true
		

#functions going down the hierarchy
func toggleSights():
	if(weapType == 1):
		activeItem.toggleADS()
		wepMesh = activeItem.getGunMesh()
		inAimingTransition = true
		notAimed = activeItem.aimDownsight
	elif(weapType == 2):
		activeItem.tryBlock()
	else:
		pass

#--------- ALL OF THESE FUNCTIONS INTERACT WITH THE USER ITEM (going UP the scene tree)
#You HAVE to implement these. Check their code in the player invenmanager for how to do so.
##Applies viewpunch, in degrees. Can be float or int.
func applyViewpunch(lift, drift):
	print("Attempted to apply viewpunch on invenmanager parent! Lift: ", lift, " Drift: ", drift)
	pass

##Space state of the camera or wherever the bullets will come from, used in shooting
func get_space_state()-> PhysicsDirectSpaceState3D:
	print("Attempted to get space state on parent! Bad!")
	return null

##Origin of where bullets are coming from
func get_Origin()-> Vector3:
	print("Attempted to get origin on invenmanager parent! Bad!")
	return Vector3(0,0,0)

##Endpoint of where bullets are coming from. Azimuth is offset, in degrees, and roll is how far around a circle
func get_End(orig:Vector3, azimuth:float, roll:float):
	print("Attempted to get origin on invenmanager parent! Bad!")
	return orig + Vector3(azimuth,roll,0)
	
func get_Rotation()-> Vector3:
	print("Attempted to get rotation on invenmanager parent! Bad!")
	return Vector3(0,0,0)
