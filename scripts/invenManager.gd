extends Node3D
	
enum Ammotypes {ammoBlank, ammoPistol, ammoRifle}
var heldAmmunition = {} # dictionary of all the player's held ammotypes and ammo
var reloading = false
@onready var heldItem = $debug_gun 

#@export var WEP_TYPE: Wep
#@onready var weapon_mesh: MeshInstance3D = $held_weapon

func withdrawAmmo(amTyp, amount):
	if(amTyp == 1):
		print("Taking ", amount, " from pool of ", heldAmmunition.ammoPistol)
		if(amount >= heldAmmunition.ammoPistol):
			
			
			print("making do with ", heldAmmunition.ammoPistol)
			var leftover = heldAmmunition.ammoPistol
			heldAmmunition.ammoPistol = 0
			return leftover
		
		heldAmmunition.ammoPistol -= amount;
		return amount
	
		
	else:
		print("Tried to update invalid ammo type!")

func getAmmoAmt(amTyp) -> int:
	
	#print("requested chambering: ", amTyp)
	if(amTyp == 1):
		return heldAmmunition.ammoPistol
	else:
		print("Invalid chambering!!!")
		return 0;
	#return heldAmmunition.amTyp
	
func _init():#wepRef):
	heldAmmunition.ammoBlank = 100
	heldAmmunition.ammoPistol = 16
	heldAmmunition.ammoRifle = 20
	
	#load_weapon()
#
#func load_weapon():
	#
	#print("hi!")
	#print("Loading mesh: ", WEP_TYPE.mesh)
	#weapon_mesh.mesh = WEP_TYPE.mesh
	#
	#position = WEP_TYPE.position
	#rotation_degrees = WEP_TYPE.rotation
	#scale = WEP_TYPE.scale
	#
	#inventory manager function that tells the held item to attempt shooting
func doShoot():
	heldItem.tryShoot()
	
	#inventory manager function that tells the held item to attempt reloading
func startReload():
	
	
	heldItem.startReload()
	
	#if(!reloading):
		##TODO: logic here to determine if we CAN reload
		#print("starting reload! 9mm ammo: ", heldAmmunition.ammoPistol);
		#reloadtimer.start()
		#reloading = true
	#

# this will be called ONCE the reload timer is finished
#func _on_timer_timeout() -> void:
	#if (reloading):
		#heldItem.doReload()
		#reloading = false
	#else:
		#pass # Replace with function body.
