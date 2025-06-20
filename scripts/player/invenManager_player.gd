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
	
	heldItem.load_weapon(heldItem.Starting_Wep, true)
	
	holdingFirearm = heldItem.isFirearm

func getRefs():
	heldItem = get_node("weaponHolder")
	user = get_node("../../..")

#functions going down the hierarchy
func doShoot():
	if(holdingFirearm):
		heldItem.tryShoot()
	else:
		print("Swing!")

func startReload():
	if(holdingFirearm):
		heldItem.startReload()
	else:
		print("How do you reload a sword?")
	
func toggleSights():
	if(holdingFirearm):
		heldItem.toggleADS()
	else:
		print("Parry!")
	
#Functions going up the hierarchy
##Apply viewpunch to the player, in degrees. Requires a connected user object.
func applyViewpunch(lift, drift):
	user.apply_Viewpunch(lift, drift)

func get_space_state():
	return user.playerCam.get_world_3d().direct_space_state 
	 
func get_Origin():
	return user.playerCam.project_ray_origin(get_viewport().size / 2)
	
##Endpoint of where bullets are coming from. Lift and Drift are for inaccuracy calculations.
func get_End(orig, drift, lift):
	
	
	# TODO: just fucking use trig, man.
	#subtract end and origin to get 2 right triangles. 
	
	#the important part of this code is project ray normal
	var end:Vector3 = orig + user.playerCam.project_ray_normal(get_viewport().size / 2) * 1000
	
	#Why are we using up and forwards here?
	#Because they're our axes of rotation. 
	var upAxis = Vector3.UP 
	var sideAxis = Vector3.FORWARD
	#in these cases the player's rotation is either -1.5 or 1.5.
	
	
	#TODO: is it worth using the raycast object for this and rotating it the user friendly way?
	#this works BUT spread is now global.
	#player up rotation stays between 1.5 and -1.5
	upAxis = Vector3(0, user.playerCam.rotation.x / 1.5, 0) #x is the up/down rotation of the playercam
	
	var actualYRotationRadians = ((int(user.playerCam.rotation.y / 1.5) * 1.5)/6 ) #dunno why we need to divide a six out of here but we in fact do.
	print(actualYRotationRadians)
	actualYRotationRadians = user.playerCam.rotation.y - (actualYRotationRadians * 1.5)
	print(actualYRotationRadians)
	
	
	#print(user.playerCam.rotation.x)
	#sideAxis = Vector3(0, 0, user.playerCam.rotation.x / 1.5)
	
	#upAxis.rotated(Vector3.LEFT, user.playerCam.rotation.y)
	
	#solution idea 1: rotate the axis by the player's up/down axis, thus making it "constant"
	#WRT player's angle.
	
	#var upAxis = Vector3(0, user.playerCam.rotation.y, 0) #get an axis of rotation for up/down from camera
	#var sideAxis = Vector3(user.playerCam.rotation.x, 0, 0) #ditto for azimuth
	##end = end.rotated(, deg_to_rad(lift)) #rotate
	
	#This works UNTIL the player is lookin
	end = end.rotated(upAxis.normalized(), deg_to_rad(drift)) 
	
	return end 
	
func get_Rotation():
	return user.playerCam.rotation
