#this is THE script that keeps tabs on player ammunition, tells weapons how much they can
# reload by, and conveys commands from the player to the held weapon.
#it answers directly to the player script and commands the held_weapon_behavior script

class_name PLAYERINVENMANAGER extends INVENMANAGER

var weight = 0 ##The current held ammo pool's "weight"
var maxweight = 3000 ##A generous, but reasonable maximum amount of ammo that can be held
@onready var uiInfo = $"../../../Player UI"
@export var ourHands: WEAP_INFO

var currentSlot: int = 1
var slot1: INVWEP ##TODO: eventually replace these with slot arrays.
var slot2: INVWEP

func _ready():
	
	print("Hello and welcome to Sylphstream!")
	
	user = get_node("../../..")
	
	heldAmmunition.ammoRimfire = 100
	heldAmmunition.ammoPistol = 51
	heldAmmunition.ammoRifle = 30
	heldAmmunition.ammoShotgun = 20
	recalcWeight()
	
	await get_tree().create_timer(0.1).timeout
	#add hands and starter weapon to our inventory
	uiInfo.ammoCounter.hideElements()
	add_To_Slot(ourHands, 1, null) #put empty hands into our inventory
	add_To_Slot(starterWeapon, 2, starterWeapon.maxCapacity)
	
	#load our hands and override weaptype
	load_Wep(ourHands)
	weapType = 0


func load_Wep(wep2Load):
	super(wep2Load)
	
	if(weapType == 1): #handle firearm UI
		activeItem.give_Player_UI(uiInfo)
		
		#nothing other than MANUALLY GRABBING THE DIRECT  REFERENCE works here >:(
		var giveMeTheDamnReferenceSoHelpMeGod = $"../../../Player UI/Ammo/Currentmag"
		giveMeTheDamnReferenceSoHelpMeGod.text = str(wep2Load.maxCapacity)
		var reserve = $"../../../Player UI/Ammo/reserve"
		reserve.text = str(chkAmmoAmt(wep2Load.chambering))
		var gunName = $"../../../Player UI/Ammo/name"
		gunName.text = wep2Load.wepName
	

var weight22 = 1 ##Weight of 22 rimfire rounds
var weightpistol = 3 ##weight of pistol rounds
var weightrifle = 5 ##Weight of small rifle rounds
var weight30cal = 7 ##weight of large rifle rounds
var weightShotgun = 10 ##Weight of shotgun shells
var weightRimmed = 4 ## Weight of magnum rounds

func recalcWeight():
	weight = 0
	weight += weight22 * heldAmmunition.ammoRimfire
	weight += weightpistol * heldAmmunition.ammoPistol
	weight += weightrifle * heldAmmunition.ammoRifle
	weight += weightShotgun * heldAmmunition.ammoShotgun
	#print("Current ammo weight: ", weight)

#TODO: eventually use slot arrays
##Puts a weapon into an inventory slot. DOES NOT UNLOAD THE WEAPON. JUST UPDATES SLOT INFO.
func add_To_Slot(weapon: WEAP_INFO, slot: int, rounds):
	if(slot == 1):
		slot1 = INVWEP.new()
		slot1.slotUsed = weapon.selection
		slot1.theWeapon = weapon
		if(rounds):
			slot1.roundInside = rounds
		else:
			slot1.roundInside  = 0
	if(slot == 2):
		slot2 = INVWEP.new()
		slot2.slotUsed = weapon.selection
		slot2.theWeapon = weapon
		if(rounds):
			slot2.roundInside = rounds
		else:
			slot2.roundInside  = 0

##Unloads the current weapon and loads a weapon out of the given slot
func change_To_Slot(newSlot: int):
	
	#TODO: add stow and draw times
	
	if(currentSlot == newSlot): #if we aren't getting out a new weapon, don't bother
		return #TODO: change this to cycle through the current slot when you add slotarrays
	else: 
		#put the current weapon away (update our inventory)
		if(weapType == 1):
			add_To_Slot(activeItem.ourDataSheet, currentSlot, activeItem.capacity)
		elif(weapType == 0): 
			add_To_Slot(activeItem.ourDataSheet, currentSlot, null)
			#TODO: ENABLE UI because we are putting away hands
		
		#since the load weapon script already deals with unloading stuff, we dont have to do too much
		if(newSlot == 1): #special case for loading hands
			load_Wep(slot1.theWeapon)
			#TODO: DISABLE UI
		elif(newSlot == 2): #otherwise just load normally
			load_Wep(slot2.theWeapon)
			if(weapType == 1): #if we have a gun, dont assume we start with default ammo count
				activeItem.capacity = slot2.roundInside
			

#everything below here is standard stuff, just with some overrides

func _process(delta):
	if(activeItem):
		activeItem.manualProcess(delta)

##Gives ammo to invenmanager and updates ammo weight
func giveAmmo(amTyp: int, amount: int):
	var result = super.giveAmmo(amTyp, amount)
	uiInfo.ammoCounter.updateReserve(result)
	recalcWeight()
	return result

##Withdraws ammo from invenmanager and updates weight
func withdrawAmmo(amTyp: int, amount: int)-> int:
	var result = super.withdrawAmmo(amTyp, amount)
	recalcWeight()
	uiInfo.ammoCounter.updateReserve(result)
	return result
	

#functions going down the hierarchy
func toggleSights():
	if(weapType == 1):
		activeItem.toggleADS()
	else:
		pass
	
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
