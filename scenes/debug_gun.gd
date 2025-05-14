extends Node3D
@onready var reloadtimer = $debugReloadtimer
#script to be depricated

const wepName  = "imcoder!"
const selection = 1
@onready var manager = $".."
var chambering : int
const maxCapacity = 8
var capacity = 0
var reloadtime = 1.5

const reloadDuration = 4
var reloadTime = 0


func _init():#ammoTypes, assignedManager):
	chambering = 1 # pistol
	#pass
	#print("gun parent loaded!")
	#chambering = ammoTypes.ammoPistol
	#manager = assignedManager
	capacity = maxCapacity
	#

func tryShoot():
	
	if(capacity > 0):
		print("pew!!!!")
		capacity-=1
	else:
		print("click!")
		
#
#func _process(delta):
	#
	#print("hi?!")
	#if(reloading):
		#print("Reloading!")
		#if(reloadTime >= reloadDuration):
			#finishReload();
			#return
		#reloadTime += 1; #include delta in here after you get it to work

func startReload():
	reloadtimer.start();


#func doReload():
	


func _on_debug_reloadtimer_timeout() -> void:
	var ammoPool = manager.getAmmoAmt(chambering)
	var takenAmount = 0;
	#if(ammoPool >= maxCapacity):
	takenAmount += (maxCapacity - capacity)
		 #need to do partial reloads
		
	if(capacity > 0):
		takenAmount+=1
	
	print("  Capacity prior to update: ", capacity)
	
	var newCap = manager.withdrawAmmo(chambering, takenAmount)
	print("  withdrawn ammo: ", newCap)
	
	capacity += newCap
	print("  Finished reload! Rounds: ", capacity)
