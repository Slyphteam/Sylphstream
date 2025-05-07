extends Node3D
const wepName  = "imcoder!"
const selection = 1
var chambering : int
const maxCapacity = 22
var capacity = 0


func _init(ammoTypes):
	print("gun parent loaded!")
	chambering = ammoTypes.ninemm
	capacity = maxCapacity
	

func tryShoot():
	capacity-=1
	
	if(capacity > 0):
		print("pew!")
	else:
		print("click!")
