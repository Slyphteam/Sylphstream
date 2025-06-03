#this is THE script that keeps tabs on player ammunition, tells weapons how much they can
# reload by, and conveys commands from the player to the held weapon.
#it answers directly to the player script and commands the held_weapon_behavior script

extends Node3D

enum Ammotypes {ammoBlank, ammoPistol, ammoRifle}
var heldAmmunition = {} # dictionary of all the player's held ammotypes and ammo
var reloading = false
@onready var heldItem = $weaponHolder
@onready var player = $"../.."

func withdrawAmmo(amTyp, amount):
	print("Selected type ", amTyp)
	if (amTyp == 1):
		print("Taking ", amount, " from pool of ", heldAmmunition.ammoPistol)
		if(amount >= heldAmmunition.ammoPistol):
			print("making do with ", heldAmmunition.ammoPistol)
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
	else:
		print("Attemted to withdraw invalid chambering!")

func getAmmoAmt(amTyp) -> int:
	
	#print("requested chambering: ", amTyp)
	if(amTyp == 1):
		return heldAmmunition.ammoPistol
	elif(amTyp == 2):
		return heldAmmunition.ammoRifle
	else:
		print("Attempted to check invalid chambering!")
		return 0;
	#return heldAmmunition.amTyp

func _init():#wepRef):
	print("Hello and welcome to Sylphstream!")
	heldAmmunition.ammoBlank = 100
	heldAmmunition.ammoPistol = 51
	heldAmmunition.ammoRifle = 30
	
#functions going down the hierarchy

func doShoot():
	heldItem.tryShoot()

func startReload():
	heldItem.startReload()

func toggleSights():
	heldItem.toggleADS()
	#if(aimdownsights):
		#print("Obliterating accuracy")
		#heldItem.adjustAcuracy(50)
		#aimdownsights = false
		#return
	#else:
	#print("Aiming")
	#heldItem.adjustAcuracy(-10)
	
#
#func update_aim():
	#pass

#Functions going up the hierarchy
##Apply viewpunch to the player, in degrees. Requires a connected player object.
func applyViewpunch(azimuth, zenith):
	player.apply_Viewpunch(azimuth, zenith)

func get_space_state():
	return player.playerCam.get_world_3d().direct_space_state 
	 
func get_Origin():
	return player.playerCam.project_ray_origin(get_viewport().size / 2)
	
func get_End(orig, lift, drift):
	#return orig + player.playerCam.project_ray_normal(get_viewport().size / 2) * 1000
	

	var end:Vector3 = orig + player.playerCam.project_ray_normal(get_viewport().size / 2) * 1000
	var upAxis = Vector3(0, player.playerCam.rotation.y, 0) #get an axis of rotation for up/down from camera
	var sideAxis = Vector3(player.playerCam.rotation.x, 0, 0) #ditto for azimuth
	end = end.rotated(upAxis.normalized(), deg_to_rad(lift)) #rotate
	end = end.rotated(sideAxis.normalized(), deg_to_rad(drift))
	
	return end 
	
func get_Rotation():
	return player.playerCam.rotation
