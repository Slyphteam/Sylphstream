class_name SYLPHINVENMANAGER extends INVENMANAGER
##This is the Sylph's invenmanager script. Similar, but slightly different to player invenmanager script.

@onready var sylphHead = $".."
@onready var sylphMind = $"../../slyph mind"

func _ready():
	pass
	#no need to actually do anything on ready, yet.
	#print("Hello and welcome to Sylphstream!")
	#heldAmmunition.ammoBlank = 10000
	heldAmmunition.ammoPistol = 10000
	#heldAmmunition.ammoRifle = 30
	
	getRefs()
	
	heldItem.load_weapon(heldItem.Starting_Wep, false)
	
	holdingFirearm = heldItem.isFirearm

func get_Ammo_Left():
	var ratio:float = 1
	var cur:float = heldItem.capacity
	var ma:float = heldItem.maxCapacity
	if(heldItem.capacity != heldItem.maxCapacity):
		ratio = cur / ma #value from 0-1
	ratio *=2 #value from 0-2
	ratio -=1 #value from -1 - 1
	return ratio

func getRefs():
	heldItem = $weaponHolder
	user = $"../.."

##functions going down the hierarchy
var penalty = 0

func startReload():
	if(holdingFirearm):
		heldItem.startReload()
		penalty = heldItem.penalty
	else:
		print("How do you reload a sword?")

func toggleSights():
	pass
	#if(holdingFirearm):
		#heldItem.toggleADS()
	#else:
		#print("Parry!")
	#
##Functions going up the hierarchy
###Apply viewpunch to the player, in degrees. Requires a connected user object.
func applyViewpunch(lift, drift):
	#print("Sylph is ignoring upwards recoil of ", lift)
	user.move_Head_Exact([0, drift]) 

func get_space_state():
	return user.sylphHead.get_world_3d().direct_space_state 
	
func get_Origin(): #tested and seems to work.

	var orig = sylphHead.global_position 
	
	return orig
	
##Endpoint of where bullets are coming from. Azimuth is offset, in degrees, and roll is how far around a circle
func get_End(orig:Vector3, _azimuth:float, _roll:float):
	var pathVec = Vector3(20, 0, 0)
	var desired = sylphHead.rotation
	
	pathVec = pathVec.rotated(Vector3.FORWARD, desired.x) #vertical
	pathVec = pathVec.rotated(Vector3.UP, desired.y) #horizontal
	
	
	#no need to do Z since we know we aren't rolling
	pathVec += orig #add the rotated vector to wherever it's coming from
	
	#print(pathVec)
	return pathVec
	
func get_Rotation():
	return user.sylphHead.rotation
