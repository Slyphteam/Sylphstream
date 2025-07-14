#This is the boilerplate code for all invenmanager objects.
class_name INVENMANAGER extends Node3D

@export var starterWeapon: WEAP_INFO
enum Ammotypes {ammoRimfire, ammoPistol, ammoRifle, ammoThirtycal, ammoShotgun}
var heldAmmunition = {} # dictionary of all the player's held ammotypes and ammo
var reloading = false
#var heldItem: Node3D #old name for activeItem prior to the WEPINSTANCE refactor
var activeItem: WEPINSTANCE
var weapType: int ##1 for basic firearm, 2 for melee...
var user : Node3D

#var holdingFirearm: bool = false

#func _ready():
	#

##Get references to helditem and user. should be called in ready; here because it's not optional
func getRefs():
	pass

##Loads a WEPINSTANCE using universal logic.
func load_Wep(wep2Load):
	
	if(activeItem): #unload old item
		activeItem.unload()
		activeItem.queue_free()
		activeItem = null
	
	
	if(wep2Load is FIREARM_INFO):
		if(wep2Load.shotgunMode):
			activeItem = SHOTGUNINSTANCE.new()
			activeItem.invManager = self
			activeItem.load_Weapon(wep2Load)
			weapType = 1 #still use the firearm control schema
		else:
			activeItem = GUNBASICINSTANCE.new()
			activeItem.invManager = self
			activeItem.load_Weapon(wep2Load)
			weapType = 1 #basic gun
	else:
		print("Unsupported script override!")


#--------- ALL OF THESE FUNCTIONS EXIST INTERNALLY WITH THE INVENMANAGER
func giveAmmo(amTyp: int, amount: int):
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
	

##Decrease ammo of desired type by desired amount
func withdrawAmmo(amTyp: int, amount: int)-> int:
	#print("Selected type ", amTyp)
	if (amTyp == 1):
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
func getAmmoAmt(amTyp:int ) -> int:
	#print("requested chambering: ", amTyp)
	if(amTyp == 1):
		return heldAmmunition.ammoPistol
	elif(amTyp == 2):
		return heldAmmunition.ammoRifle
	elif(amTyp == 4):
		return heldAmmunition.ammoShotgun
	else:
		print("Attempted to check invalid chambering!")
		return 0;
	#return heldAmmunition.amTyp

#--------- ALL OF THESE FUNCTIONS INTERACT WITH THE HELD ITEM (going DOWN the scene tree)


func doShoot():
	if(weapType == 1):
		activeItem.triggerDepressed = true
	else:
		print("Swing!")

func unShoot():
	if(weapType == 1):
		activeItem.triggerDepressed = false
	
func startReload():
	#penalty
	if(weapType == 1):
		activeItem.startReload()
	else:
		print("How do you reload a sword?")

func toggleSights():
	#heldItem.toggleADS()
	print("Attempted to call empty aim function!")
	

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
