#this is THE script that keeps tabs on player ammunition, tells weapons how much they can
# reload by, and conveys commands from the player to the held weapon.
#it answers directly to the player script and commands the held_weapon_behavior script

class_name PLAYERINVENMANAGER extends INVENMANAGER

var weight = 0 ##The current held ammo pool's "weight"
@onready var uiInfo = $"../../../Player UI"
@onready var healthHolder = $"../../../Player Health"
@export var ourHands: WEAP_INFO
@export var secondStarter: WEAP_INFO 


var maxweight = 1350 ##lets say 9 30-round mags of 5.56 (9*30*5) as a reasonable maximum amount of ammo weight

var allSlots: Array #2D matrix of all five slots.

var currentSlot: int = 1 ##Which of the 4 invslots are we on?
var slotSelection: int = 0 ##Which index into said slot are we?

var slotMaxes = 2 ##Will change once out of alpha, but for now max of 2 weapons per slot.

var slot1: Array[INVWEP] ##Custom slot exclusively for the hands
var slot2: Array[INVWEP] ##Holster slots.
var slot3: Array[INVWEP] ##chest slots
var slot4: Array[INVWEP] ##Back slots
var slot5: Array[INVWEP] ##Sheathe slots

#Okay, time to talk about selection slots.
#Player inventory has 5 slots, 4 of which weapons can go into. Each weapon MUST have a default slot,
# but weapons can have multiple valid slots. (E.X. a rifle can go on the chest and back).
#They are as follow:
#Slot 1: hands. Player should never ever not have hands slot. 
#Slot 2: hips. Pistols, swords, knives, exceptionally small SMGs. Think scabbard/holster
#Slot 3: Chest. Small rifles, smgs, some large pistols go here. Think single point sling,
#Slot 4: Back. Medium and large rifles, large melee. Think slings.
#Slot 5: Sheathe. Players should always be able to carry a small melee on them.


func _ready():
	
	print("Hello and welcome to Sylphstream!")
	
	user = get_node("../../..")
	
	heldAmmunition.ammoRimfire = 0
	heldAmmunition.ammoPistol = 0
	heldAmmunition.ammoRifle = 0
	heldAmmunition.ammoShotgun = 0
	recalcWeight()
	
	allSlots.resize(5)
	
	#Populate our inventory with the slotarrays
	allSlots[1] = slot2
	allSlots[2] = slot3
	allSlots[3] = slot4
	allSlots[4] = slot5
	
	##Add 2 starter pistols
	if(starterWeapon):
		add_To_Slot(starterWeapon, starterWeapon.selections[0])
	if(secondStarter):
		add_To_Slot(secondStarter, starterWeapon.selections[0])
	
	#load our hands and override weaptype
	#Manually add our hands to slot1
	var theHands = INVWEP.new()
	theHands.slotUsed = 1
	theHands.theWeapon = ourHands
	theHands.roundInside  = 0
	slot1.resize(1)
	slot1[0] = theHands #slightly weird way but it ensures that everything is airtight
	allSlots[0] = slot1
	
	load_Wep(ourHands)
	await get_tree().create_timer(0.1).timeout #wait one tenth of a second because it takes a bit longer for ui to init
	uiInfo.hide_Ammo_Elements()
	

#----------------Inventory management functions

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
	
	elif(weapType == 2):
		activeItem.give_Player_UI(uiInfo)
		var giveMeTheDamnReferenceSoHelpMeGod = $"../../../Player UI/Ammo/Currentmag"
		giveMeTheDamnReferenceSoHelpMeGod.text = ""
		var reserve = $"../../../Player UI/Ammo/reserve"
		reserve.text = ""
		var gunName = $"../../../Player UI/Ammo/name"
		gunName.text = wep2Load.wepName
	
	elif(weapType == 0): #if weapon is bare hands, reset our crosshair size to default
		uiInfo.crosshair_Reset_Size()
	

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

##Updates the information of a weapon stowed in a slot.
func update_To_Slot(weapon: WEAP_INFO, slot: int, rounds):
	if(slot == 1):
		return
	if(slot == 2):
		if(weapType == 1):
			slot2[slotSelection].roundInside = rounds
	#nothing else to do...


##Puts a new weapon into an inventory slot. DOES NOT UNLOAD THE WEAPON. Returns if it could fit.
func add_To_Slot(weapon: WEAP_INFO, slot: int)->bool:
	#commented this out because support for literally anything going into hand slots seems like a bad idea
	#if(slot == 1):
		#slot1 = INVWEP.new()
		#slot1.slotUsed = weapon.selection
		#slot1.theWeapon = weapon
		#if(rounds):
			#slot1.roundInside = rounds
		#else:
			#slot1.roundInside  = 0
	
	var chosenSlot = allSlots[slot - 1]
	
	if(chosenSlot.size() >= slotMaxes): #cant fit anything else into a slot
		return false
	
	var newInvwep = INVWEP.new()
	newInvwep.slotUsed = slot
	newInvwep.theWeapon = weapon
	
	if(weapon is FIREARM_INFO):
		newInvwep.roundInside = weapon.maxCapacity
	else:
		newInvwep.roundInside  = 0
	
	chosenSlot.resize(chosenSlot.size() + 1)
	chosenSlot[chosenSlot.size() - 1] = newInvwep
	print("Added ", weapon.wepName, " to index ", (chosenSlot.size() - 1), " of slot ", slot)
	
	return true
	
	#it seems like going from pistol to hands doesnt update current slot.
##Unloads held weapon, then loads weapon out of newSlot. Uses hl2-like logic to decide which weapon.
func change_To_Slot(newSlot: int):
	
	var newSlotArr = allSlots[newSlot - 1]
	if(newSlotArr.size() == 0): #if we cant even switch, dont bother
		return
	
	if(user.aiming): #unaim if we are ADS
		user.toggle_ADS_Stats()
	
	if(weapType == 0 && currentSlot == 1): #moving off hands
		if(newSlot == 1):  #special return case, still on hands
			currentSlot = newSlot
			return
		uiInfo.show_Ammo_Anything()
	if(weapType == 0 && currentSlot != 1): #something is fucky
		Globalscript.raise_Panic_Exception("A hands weapon is somehow trying to be loaded in the wrong slot!")
	
	if(weapType == 1): #we have a gun, update to inventory before putting away
		update_To_Slot(activeItem.ourDataSheet, currentSlot, activeItem.capacity)
	

	
	if(currentSlot == newSlot): #if we're staying in the same slot, index
		if(newSlotArr.size() == 1): # dont bother
			currentSlot = newSlot
			return

		
		slotSelection +=1
		if(slotSelection >= newSlotArr.size()):
			slotSelection = 0 #loop back to start
	else: 
		slotSelection = 0 #if we aren't, start at the top
	
	#since the load weapon script already deals with unloading stuff, we dont have to do too much
	if(newSlot == 1): #special case for loading hands, hide UI
		load_Wep(slot1[0].theWeapon) #it's kind of bad practice to be directly accessing slot1 but its such a special case
		uiInfo.hide_Ammo_Elements() 
	else: #otherwise act normal
		var drawnWep = newSlotArr[slotSelection]
		load_Wep(drawnWep.theWeapon)
		if(weapType == 1): #if we are loading a gun, dont assume we start with default ammo count
			activeItem.capacity = drawnWep.roundInside
			uiInfo.updateMag(drawnWep.roundInside)
		
	#if we've gotten this far, update our active slot
	currentSlot = newSlot

##Adds a new weapon to an inventory. Differs from add_To_Slot in that it handles slot and capacity logic.
func give_New_Weapon(weapon: WEAP_INFO, validSlots: Array[int])->bool:
	for x in validSlots.size():
		if(allSlots[validSlots[x] - 1].size() < slotMaxes): #we have room in the first of the desired slots.
			return add_To_Slot(weapon, validSlots[x])
	return false

#everything below here is standard stuff, just with some overrides


##Gives ammo to invenmanager and updates ammo weight
func giveAmmo(amTyp: int, amount: int):
	var result = super.giveAmmo(amTyp, amount)
	uiInfo.updateReserve(result)
	recalcWeight()
	return result

##Withdraws ammo from invenmanager and updates weight
func withdrawAmmo(amTyp: int, amount: int)-> int:
	var result = super.withdrawAmmo(amTyp, amount)
	recalcWeight()
	uiInfo.updateReserve(chkAmmoAmt(amTyp))
	return result
	


#----------------Autostim functions
##Tells the player healthholder to add an effect. Called when the player selects an autostim
func take_Autostim(stimNum: int):
	var theEffect: STATUSEFFECT
	if(stimNum == 1):# useless if statement for when we have more stims
		theEffect = STATUSPLACEBO.new()
	
	#add the status effect to the healthholder
	healthHolder.add_Effect(theEffect)	
		

#----------------Weapon handling functions

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
	return user.playerCam.global_rotation
