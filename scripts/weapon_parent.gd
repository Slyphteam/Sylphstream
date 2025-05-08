extends Node3D
const wepName  = "imcoder!"
const selection = 1
var manager
var chambering : int
const maxCapacity = 8
var capacity = 0

const reloadDuration = 4
var reloadTime = 0
var reloading = false


func _init(ammoTypes, assignedManager):
	print("gun parent loaded!")
	chambering = ammoTypes.ammoPistol
	manager = assignedManager
	capacity = maxCapacity
	

func tryShoot():
	capacity-=1
	
	if(capacity > 0):
		print("pew!")
	else:
		print("click!")
		

func _process(delta):
	
	print("hi?!")
	if(reloading):
		print("Reloading!")
		if(reloadTime >= reloadDuration):
			return
			finishReload();
		reloadTime += 1; #include delta in here after you get it to work
	
func startReload():
	print("Starting reload!")
	reloading = true

func finishReload():
	var ammoPool = manager.getAmmoAmt(chambering)
	print("finished reloading!!")
	capacity = maxCapacity
	reloadTime = 0
	reloading = false
