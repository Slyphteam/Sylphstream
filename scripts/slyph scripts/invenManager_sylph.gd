class_name SYLPHINVENMANAGER extends INVENMANAGER
##This is the Sylph's invenmanager script. Similar, but slightly different to player invenmanager script.

@onready var sylphHead = $".."

func _ready():
	pass
	#no need to actually do anything on ready, yet.
	#print("Hello and welcome to Sylphstream!")
	#heldAmmunition.ammoBlank = 10000
	#heldAmmunition.ammoPistol = 51
	#heldAmmunition.ammoRifle = 30
	
	getRefs()
	
	heldItem.load_weapon(heldItem.Starting_Wep, false)
	
	holdingFirearm = heldItem.isFirearm

func getRefs():
	heldItem = $weaponHolder
	user = $"../.."

##functions going down the hierarchy
func doShoot():
	if(holdingFirearm):
		heldItem.tryShoot()
	else:
		print("Swing!")
#
func startReload():
	pass
	#if(holdingFirearm):
		#heldItem.startReload()
	#else:
		#print("How do you reload a sword?")
	#
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
	
	user.move_Head_Exact(Vector2(lift, drift)) #TODO: ensure these aren't reversed

func get_space_state():
	return user.sylphHead.get_world_3d().direct_space_state 
	
func get_Origin(): #tested and seems to work.

	var orig = sylphHead.global_position 
	#heldItem.doHitDecal(orig)
	return orig
	
##Endpoint of where bullets are coming from. Azimuth is offset, in degrees, and roll is how far around a circle
func get_End(orig:Vector3, _azimuth:float, _roll:float):
	var pathVec = Vector3(0, 0, 2)
	
	pathVec = pathVec.rotated(Vector3.UP, sylphHead.rotation.y)
	pathVec = pathVec.rotated(Vector3.RIGHT, sylphHead.rotation.x)
	
	#no need to do Z since we know we aren't rolling
	pathVec += orig #add the rotated vector to wherever it's coming from
	
	heldItem.doHitDecal(pathVec)
	print(pathVec)
	
func get_Rotation():
	return user.sylphHead.rotation
