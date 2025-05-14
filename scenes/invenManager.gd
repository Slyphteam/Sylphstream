extends Node
	
enum Ammotypes {ammoBlank, ammoPistol, ammoRifle}
var heldAmmunition = {} # dictionary of all the player's held ammotypes and ammo
var reloading = false
@onready var heldItem = $debug_gun
var modelreference


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
	#modelreference = wepRef
	#heldItem = weapParent.new(Ammotypes, self)
	#reloadtimer.wait_time = 1.5
	
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
