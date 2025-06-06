#this is THE script that keeps tabs on player ammunition, tells weapons how much they can
# reload by, and conveys commands from the player to the held weapon.
#it answers directly to the player script and commands the held_weapon_behavior script

class_name PLAYERINVENMANAGER extends INVENMANAGER

func _ready():

	print("Hello and welcome to Sylphstream!")
	heldAmmunition.ammoBlank = 100
	heldAmmunition.ammoPistol = 51
	heldAmmunition.ammoRifle = 30

	getRefs()

func getRefs():
	heldItem = get_node("weaponHolder")
	user = get_node("../../..")

#functions going down the hierarchy
func doShoot():
	heldItem.tryShoot()

func startReload():
	heldItem.startReload()

func toggleSights():
	heldItem.toggleADS()
	#if(aimdownsights):
		#print("Obliterating accuracy")
		#heldItem.adjustAcuracy(50)
		#aimdownsights = false
		#return
	#else:
	#print("Aiming")
	#heldItem.adjustAcuracy(-10)
	
#
#func update_aim():
	#pass

#Functions going up the hierarchy
##Apply viewpunch to the player, in degrees. Requires a connected user object.
func applyViewpunch(lift, drift):
	user.apply_Viewpunch(lift, drift)

func get_space_state():
	return user.playerCam.get_world_3d().direct_space_state 
	 
func get_Origin():
	return user.playerCam.project_ray_origin(get_viewport().size / 2)
	
func get_End(orig, lift, drift):
	#return orig + player.playerCam.project_ray_normal(get_viewport().size / 2) * 1000
	var end:Vector3 = orig + user.playerCam.project_ray_normal(get_viewport().size / 2) * 1000
	var upAxis = Vector3(0, user.playerCam.rotation.y, 0) #get an axis of rotation for up/down from camera
	var sideAxis = Vector3(user.playerCam.rotation.x, 0, 0) #ditto for azimuth
	end = end.rotated(upAxis.normalized(), deg_to_rad(lift)) #rotate
	end = end.rotated(sideAxis.normalized(), deg_to_rad(drift))
	
	return end 
	
func get_Rotation():
	return user.playerCam.rotation
