class_name SYLPHINVENMANAGER extends INVENMANAGER
##This is the Sylph's invenmanager script. Similar, but slightly different to player invenmanager script.

@onready var sylphHead = $".."
@onready var sylphMind = $"../../slyph mind"

func _ready():
	pass
	#no need to actually do anything on ready, yet.
	#print("Hello and welcome to Sylphstream!")
	#heldAmmunition.ammoBlank = 10000
	heldAmmunition.ammoPistol = 100000
	#heldAmmunition.ammoRifle = 30
	
	user = $"../.."
	load_Wep(starterWeapon)
	
	#moved to parent
	#if(starterWeapon is FIREARM_INFO):
		#activeItem = GUNBASICINSTANCE.new()
		#activeItem.invManager = self
		#activeItem.load_Weapon(starterWeapon, false, null)
		#weapType = 1 ##basic gun
	#else:
		#print("Unsupported script override!")
	#heldItem.load_weapon(heldItem.Starting_Wep, false)
	#
	#holdingFirearm = heldItem.isFirearm

func _process(delta):
	activeItem.manualProcess(delta)

func get_Ammo_Left():
	var ratio:float = 1
	var cur:float = activeItem.capacity
	var ma:float = activeItem.maxCapacity
	if(activeItem.capacity != activeItem.maxCapacity):
		ratio = cur / ma #value from 0-1
	ratio *=2 #value from 0-2
	ratio -=1 #value from -1 - 1
	return ratio

#Assumes that recoil will never get worse than 120
func get_Crosshair_Inaccuracy():
	var ratio = activeItem.currentRecoil
	
	ratio /= 120 #value between 0 and 1
	ratio *=2 #value between 0 and 2
	ratio -=1 #value between -1 and 1
	return 1

#func getRefs():
	#heldItem = $weaponHolder
	#user = $"../.."

##functions going down the hierarchy
var totalShots = 0 ##Used in sylph scoring

func startReload():
	
	activeItem.startReload()
	#totalShots = activeItem.totalShots
	#else:
		#print("How do you reload a sword?")

func grabShots():
	totalShots = activeItem.totalShots

##Refresh totalshots counter, replenish ammo consumed
func refreshShots():
	giveAmmo(activeItem.chambering, totalShots)
	activeItem.totalShots = 0
	totalShots = 0

func toggleSights():
	if(weapType == 1):
		activeItem.toggleADS()
	#else:
		#print("Parry!")
	#
##Functions going up the hierarchy
###Apply viewpunch to the player, in degrees. Requires a connected user object.
func applyViewpunch(lift, drift):
	user.move_Head_Exact(Vector2(lift, drift)) 

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
