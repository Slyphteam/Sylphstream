#this is THE script that keeps tabs on player ammunition, tells weapons how much they can
# reload by, and conveys commands from the player to the held weapon.
#it answers directly to the player script and commands the held_weapon_behavior script

extends Node3D

enum Ammotypes {ammoBlank, ammoPistol, ammoRifle}
var heldAmmunition = {} # dictionary of all the player's held ammotypes and ammo
var reloading = false
@onready var heldItem = $weaponHolder

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
	heldAmmunition.ammoBlank = 100
	heldAmmunition.ammoPistol = 16
	heldAmmunition.ammoRifle = 20

func doShoot():
	heldItem.tryShoot()

func startReload():
	heldItem.startReload()
