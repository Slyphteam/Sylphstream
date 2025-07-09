#this is THE script that keeps tabs on player ammunition, tells weapons how much they can
# reload by, and conveys commands from the player to the held weapon.
#it answers directly to the player script and commands the held_weapon_behavior script

class_name PLAYERINVENMANAGER extends INVENMANAGER


func _ready():
	
	print("Hello and welcome to Sylphstream!")
	heldAmmunition.ammoBlank = 100
	heldAmmunition.ammoPistol = 51
	heldAmmunition.ammoRifle = 30
	heldAmmunition.ammoShotgun = 20
	
	
	user = get_node("../../..")
	load_Wep(starterWeapon)
	
	#heldItem.load_weapon(heldItem.Starting_Wep, true)
	
	#holdingFirearm = heldItem.isFirearm

func load_Wep(wep2Load):
	
	if(activeItem): #unload old item
		activeItem.unload()
		activeItem.queue_free()
		activeItem = null
	
	if(wep2Load is FIREARM_INFO):
		activeItem = GUNBASICINSTANCE.new()
		activeItem.invManager = self
		activeItem.load_Weapon(wep2Load, true, $"../../../Control/Reticle")
		weapType = 1 ##basic gun
	else:
		print("Unsupported script override!")


func _process(_delta):
	activeItem.manualProcess()


#functions going down the hierarchy

func toggleSights():
	if(weapType == 1):
		activeItem.toggleADS()
	else:
		print("Parry!")
	
#Functions going up the hierarchy
##Apply viewpunch to the player, in degrees. Requires a connected user object.
func applyViewpunch(lift, drift):
	user.apply_Viewpunch(lift, drift)

func get_space_state():
	return user.playerCam.get_world_3d().direct_space_state 
	 
func get_Origin():
	var orig = user.playerCam.project_ray_origin(get_viewport().size / 2)
	#heldItem.doHitDecal(orig) positional debug code ignore
	#var orig2 = user.playerCam.global_position#head position?
	#heldItem.doHitDecal(orig2)
	return orig

	
##Endpoint of where bullets are coming from. Azimuth is offset, in degrees, and roll is how far around a circle
func get_End(orig:Vector3, azimuth:float, roll:float):
	
	var end:Vector3 = orig + user.playerCam.project_ray_normal(get_viewport().size / 2) * 100
	
	#so, now we have the vector that is the raycast we're making.
	var spatialVec = Vector3(orig.x - end.x, orig.y - end.y, orig.z - end.z)
	#How do we rotate it?
	#We can use vec3.up and left to rotate WRT the world's basis vectors,
	#but falls apart the closer we get to looking in the direction of said basis vector.
	#while we can trig things out, we can also just find our own basis vectors that rotate 
	#W.R.T/ the player's view. In other words, the orthonormal vectors of our spatial raycast.
	
	#great! how the frick heck can one actually generate an orthogonal vector?
	#first of all. normalize it. no icky yucky lengths
	var newBasis1 = spatialVec.normalized()
	#second of all. rotate it by 90 degrees. I'm doing up but it can be literally 
	#anything because we're just finding a basis
	var newBasis2 = newBasis1.rotated(Vector3.UP, deg_to_rad(90))
	#now, ordinarily, we'd fine a second basis vector by rotating the first
	#var newBasis3 = newBasis2.rotated(Vector3.BACK, deg_to_rad(90))
	
	#but we don't actually need to do any of that! we have everything we need to
	#displace our bullet if, rather than x offset and y offset, we
	#instead use radius (calculated using basis2 as an axis)
	#and radians, or how far AROUND a circle we are (using basis 1 as an axis)
	
	#this also lets us avoid the issue of the offsets flipping if we turn 180,
	#(I.e. a 20degree offset going from left to right if we face from west to east)
	#since all parameters are DIRECTLY tied to screenspace.
		
	spatialVec = spatialVec.rotated(newBasis2.normalized(), deg_to_rad(azimuth)) #how far from center?
	spatialVec = spatialVec.rotated(newBasis1.normalized(), deg_to_rad(roll)) #and what angle is that farness?
	
	#print(orig)
	#print(end)
	#print(newEnd)
	
	#re-construct the altered endpoint of our raycast
	var newEnd = Vector3(orig.x - spatialVec.x, orig.y - spatialVec.y, orig.z - spatialVec.z)
	return newEnd 
	
func get_Rotation():
	return user.playerCam.rotation
