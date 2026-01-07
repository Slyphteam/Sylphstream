# this is a DEPRECATED script that has been superceded by held_weapon_behavior and later GUN_BASIC_INSTANCE
#It acts in much the same way, but only works for a single weapon and does not load
#from any external resources.

extends Node3D
@onready var reloadtimer = $debugReloadtimer

const wepName  = "imcoder!"
const selection = 1
@onready var manager = $".."
var chambering : int
const maxCapacity = 8
var capacity = 0
const reloadDuration = 4
var reloading = false


func _init():
	chambering = 1 # pistol
	capacity = maxCapacity

func tryShoot():

	if(capacity > 0):
		print("pew!!!!")
		capacity-=1
	else:
		print("click!")
		

func startReload():

	if(!reloading):
		print("Starting reload!")
		reloading = true
		reloadtimer.start();


# this is the function that handles all reloading
func _on_debug_reloadtimer_timeout() -> void:
	reloading = false
	var ammoPool = manager.getAmmoAmt(chambering)
	var takenAmount = 0;
	takenAmount += (maxCapacity - capacity)
		
	if(capacity > 0):
		takenAmount+=1

	var newCap = manager.withdrawAmmo(chambering, takenAmount)
	
	capacity += newCap
	print("Finished reload! Rounds: ", capacity)
