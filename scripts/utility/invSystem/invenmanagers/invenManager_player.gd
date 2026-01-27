#this is THE script that keeps tabs on player ammunition, tells weapons how much they can
# reload by, and conveys commands from the player to the held weapon.
#it answers directly to the player script and commands the held_weapon_behavior script

class_name PLAYERINVENMANAGER extends INVENMANAGER

var ammoWeight = 0 ##The current held ammo pool's "weight"
@onready var uiInfo = $"../../../Player UI"
@onready var healthHolder = $"../../../Player Health"
@export var ourHands: INVWEP
@export var secondStarter: INVWEP 


var maxweight = 1350 ##lets say 9 30-round mags of 5.56 (9*30*5) as a reasonable maximum amount of ammo weight

var allSlots: Array ##2D array of all five weapon slots.
@export var genericItems: Array[INVENITEMPARENT] ##Array that holds generic items, formerly itemsTest

var currentSlot: int = 1 ##Which of the 4 invslots are we on?
var slotSelection: int = 0 ##Which index into said slot are we?

var slotMaxes:Array[int] = [1,2,2,2,1] ##Array of all the slot maximums: hand, holster, chest, back, sheathe

var ammoWeightInfo:Array[int] = [1,3,5,7,10,4]

var weight22 = 1 ##Weight of 22 rimfire rounds
var weightpistol = 3 ##weight of pistol rounds
var weightrifle = 5 ##Weight of small rifle rounds
var weight30cal = 7 ##weight of large rifle rounds
var weightShotgun = 10 ##Weight of shotgun shells
var weightRimmed = 4 ## Weight of magnum rounds

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
	heldAmmunition.ammoThirtycal = 0
	heldAmmunition.ammoShotgun = 0
	heldAmmunition.ammoMagnum = 0
	
	recalc_Weight()
	
	#Begin with slot init
	allSlots.resize(5)
	genericItems.resize(6)
	
	slot1.resize(slotMaxes[0])
	slot1[0] = ourHands #slightly weird way but it ensures that everything is airtight
	allSlots[0] = slot1
	
	#Populate our generic slots
	
	
	#Populate the remaining arrays
	for x in range(slotMaxes[1]): #hips
		slot2.append(null)
	allSlots[1] = slot2
	
	for x in range(slotMaxes[2]): #chest
		slot3.append(null)
	allSlots[2] = slot3
	
	for x in range(slotMaxes[3]): #back
		slot4.append(null)
	allSlots[3] = slot4
	
	for x in range(slotMaxes[4]): #sheathe
		slot5.append(null)
	allSlots[4] = slot5
	
	##Add 2 starter pistols
	if(starterWeapon):
		add_InvWeap_To_Slot(starterWeapon, starterWeapon.weapInfoSheet.selections[0])
	if(secondStarter):
		add_InvWeap_To_Slot(secondStarter, starterWeapon.weapInfoSheet.selections[0])
	
	#always load hands to start
	load_Wep(ourHands.weapInfoSheet)
	await get_tree().create_timer(0.1).timeout #wait one tenth of a second because it takes a bit longer for ui to init
	uiInfo.hide_Ammo_Elements()
	

#----------------Inventory management functions
##Create an active weapon instance from a wepinfo datasheet
func load_Wep(wep2Load: WEAP_INFO):
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
	





#===============> INVENSYSTEM STUFF
func consume_item(thingToGive):
	if(thingToGive is INVWEP):
		return give_New_InvWeap(thingToGive, thingToGive.weapInfoSheet.selections)
	elif(thingToGive is INVAMMBOX):
		for x in range (thingToGive.arrLength):
			#ammo boxes will always return true because the check to delete or preserve them
			#happens on the pickup side of the script. what we gotta worry about is cramming as much as we can carry
			#and updating the data to account for what we can't
			thingToGive.amtArr[x] = giveAmmo(thingToGive.typeArr[x], thingToGive.amtArr[x])
		return true
	else:
		return add_GenericItem(thingToGive)
	
	return false

##Adds a generic item to genericItems array if it can
func add_GenericItem(thingToGive:INVENITEMPARENT)->bool:
	
	var itemCheck
	for x in range(genericItems.size()):
		itemCheck = genericItems[x]
		if(itemCheck == null):
			genericItems[x] = thingToGive
			return true
	
	return false

#=============== WEAPON STUFF
##Updats the counted rounds tracked by a weapon invenitem
func update_Slot(slot:int, rounds):
	if(slot == 1):
		return
	else:
		var curArr = allSlots[slot -1]
		curArr[slotSelection].roundInside = rounds
		

##Updates the information of a weapon stowed in a slot.
#func update_To_Slot(weapon: WEAP_INFO, slot: int, rounds):
	#if(slot == 1):
		#return
	#if(slot == 2):
		#if(weapType == 1):
			#slot2[slotSelection].roundInside = rounds
	#nothing else to do...
##Function that adds an invenitem to a selected slot. 
func add_InvWeap_To_Slot(invWeapon:INVWEP, slot:int)->bool:
	var chosenSlot = allSlots[slot - 1]
	
	#Check if we have any empty entries in our selected array
	var hasEmpty = false
	var emptyInd = 0
	for curItem in allSlots[slot - 1]:
		if(curItem == null):
			hasEmpty = true
			break #We want the FIRST empty slot, not the last one
		emptyInd +=1
	
	if(hasEmpty == false):
		return false
	
	
	invWeapon.slotUsed = slot #assign our slot
	
	if(invWeapon.weapInfoSheet is FIREARM_INFO):
		invWeapon.roundInside = invWeapon.weapInfoSheet.maxCapacity
	else:
		invWeapon.roundInside  = 0
	
	chosenSlot[emptyInd] = invWeapon
	
	print("Added ", invWeapon.itemName, " to index ", (chosenSlot.size() - 1), " of slot ", slot)
	
	return true

##Puts a new weapon into an inventory slot. DOES NOT UNLOAD THE WEAPON. Returns if it could fit.
#func add_To_Slot(weapon: WEAP_INFO, slot: int)->bool:
	##commented this out because support for literally anything going into hand slots seems like a bad idea
	##if(slot == 1):
		##slot1 = INVWEP.new()
		##slot1.slotUsed = weapon.selection
		##slot1.theWeapon = weapon
		##if(rounds):
			##slot1.roundInside = rounds
		##else:
			##slot1.roundInside  = 0
	#
	#var chosenSlot = allSlots[slot - 1]
	#
	#if(chosenSlot.size() >= slotMaxes): #cant fit anything else into a slot
		#return false
	#
	#var newInvwep = INVWEP.new()
	#newInvwep.slotUsed = slot
	#newInvwep.theWeapon = weapon
	#
	#if(weapon is FIREARM_INFO):
		#newInvwep.roundInside = weapon.maxCapacity
	#else:
		#newInvwep.roundInside  = 0
	#
	#chosenSlot.resize(chosenSlot.size() + 1)
	#chosenSlot[chosenSlot.size() - 1] = newInvwep
	#print("Added ", weapon.wepName, " to index ", (chosenSlot.size() - 1), " of slot ", slot)
	#
	#return true
	
	#it seems like going from pistol to hands doesnt update current slot.
##Unloads held weapon, then loads weapon out of newSlot. Uses hl2-like logic to decide which weapon.
func change_To_Slot(newSlot: int):
	
	var selectedArr = allSlots[newSlot - 1]
	#Ensure the slot we're loading to is not in fact vacant
	var checkEmpty = false
	for curr in selectedArr:
		if(curr != null):
			checkEmpty = true
	if(checkEmpty == false):
		return
	
	if(user.aiming): #unaim if we are ADS
		user.toggle_ADS_Stats()
	
	if(weapType == 0 && currentSlot == 1): #moving off hands
		if(newSlot == 1):  #special return case, still on hands
			currentSlot = newSlot
			return
		uiInfo.show_Ammo_Anything() #name and info is set by wepinstance superclass
	if(weapType == 0 && currentSlot != 1): #something is fucky
		Globalscript.raise_Panic_Exception("A hands weapon is somehow trying to be loaded in the wrong slot!")
	
	if(weapType == 1): #we are presently holding a gun, update to inventory before putting away
		update_Slot(currentSlot, activeItem.capacity)
	
	if(currentSlot != newSlot):
		slotSelection = -1
	
	var nextWeap:INVWEP
	slotSelection +=1 #already index one into the next slot
	for x in range(selectedArr.size()):
		if(slotSelection >= selectedArr.size()): #loop to start
			slotSelection = 0
		nextWeap = selectedArr[slotSelection]
		if(nextWeap != null): #we have what we want
			break
		slotSelection +=1 #keep going
		
	
	
	#old slotSelection logic
	#if(currentSlot == newSlot): #if we're staying in the same slot, index
		#if(selectedArr.size() == 1): # dont bother
			#currentSlot = newSlot
			#return
		#slotSelection +=1
		#if(slotSelection >= selectedArr.size()):
			#slotSelection = 0 #loop back to start
	#else: 
		#slotSelection = 0 #if we aren't, start at the top
	
	#since the load weapon script already deals with unloading stuff, we dont have to do too much
	if(newSlot == 1): #special case for loading hands, hide UI
		load_Wep(slot1[0].weapInfoSheet) #it's kind of bad practice to be directly accessing slot1 but its such a special case
		uiInfo.hide_Ammo_Elements() 
	else: #otherwise act normal
		
		#print(type_string(typeof(drawnInvWep)))
		load_Wep(nextWeap.weapInfoSheet)
		if(weapType == 1): #if we are loading a gun, dont assume we start with default ammo count
			activeItem.capacity = nextWeap.roundInside
			uiInfo.updateMag(nextWeap.roundInside)
		
	#if we've gotten this far, update our active slot
	currentSlot = newSlot


func give_New_InvWeap(weapon:INVWEP, validSlots:Array[int])->bool:
	var result:bool 
	#poll through the slots our weapon wants to go into, return positive if there's any hits
	for x in validSlots.size(): 
		result = add_InvWeap_To_Slot(weapon, validSlots[x])
		if(result):
			return result
	return false

##Removes an invenweapon from the specified slot cordinates, cleans up the rest of the arrays, returns removed item. ONLY USE THIS IF YOU KNOW WHAT YOU'RE DOING.
func remove_Invwep(theSlot, theIndex)->INVWEP:
	
	#if we're currently holding the weapon we wish to remove, swap off before removing it
	if((theSlot+1 == currentSlot) && (theIndex == slotSelection)):
		change_To_Slot(1)
	
	var theWep = allSlots[theSlot][theIndex]#.itemName #since stuff is getting nulled we'll use names
	allSlots[theSlot][theIndex] = null
	
	#goes through every other index in the slot
	#print(slotMaxes[theSlot] - theIndex -1)
	var nextItem
	for x in range(slotMaxes[theSlot] - theIndex -1):
		nextItem = allSlots[theSlot][x+theIndex+1]
		if(nextItem): #if there's an item ahead, move it up a slot
			allSlots[theSlot][x+theIndex+1] = null
			allSlots[theSlot][x+theIndex] = nextItem
	
	#if our slot is affected, there's a decent chance our weapon was as well
	if((theSlot+1 == currentSlot) && !(theIndex == slotSelection)):
		var count = 0
		#go through our slot until we find a matching weapon, we'll consider that the new position for slotSelection
		for item:INVWEP in allSlots[theSlot]: 
			if(activeItem.wepName == item.weapInfoSheet.wepName):
				slotSelection = count
				break
			count+=1
	
	return theWep

##Adds a new weapon to an inventory. Differs from add_To_Slot in that it handles slot and capacity logic.
#func give_New_Weapon(weapon: WEAP_INFO, validSlots: Array[int])->bool:
	#for x in validSlots.size():
		#if(allSlots[validSlots[x] - 1].size() < slotMaxes): #we have room in the first of the desired slots.
			#return add_To_Slot(weapon, validSlots[x])
	#return false

#everything below here is standard stuff, just with some overrides

func add_Generic_Item(theItem:INVENITEMPARENT)->bool:
	
	for x in range(genericItems.size()):
		if(genericItems[x] == null):
			genericItems[x] = theItem
			return true
	
	return false

func calc_Weight(amTyp, amt):
	var result1 = ammoWeightInfo[amTyp] * amt
	
	return result1
	

func recalc_Weight():
	ammoWeight = 0
	ammoWeight += weight22 * heldAmmunition.ammoRimfire
	ammoWeight += weightpistol * heldAmmunition.ammoPistol
	ammoWeight += weightrifle * heldAmmunition.ammoRifle
	ammoWeight += weightShotgun * heldAmmunition.ammoShotgun
	ammoWeight += weight30cal * heldAmmunition.ammoThirtycal
	ammoWeight += weightRimmed * heldAmmunition.ammoMagnum
	#print("Current ammo weight: ", weight)

##Gives ammo to invenmanager and updates ammo weight, returns leftover bullets not gotten
func giveAmmo(amTyp: int, amount: int):
	
	var result:int
	var addedWeight = calc_Weight(amTyp, amount)
	if(ammoWeight + addedWeight <= maxweight): #we have enough room, easy breezy
		ammoWeight += addedWeight
		super.giveAmmo(amTyp, amount)
		result = 0
	else: #otherwise, calculate how many of the ammotype we'll need
		var actualRoom = maxweight - ammoWeight
		var ammountAccepted = floor(actualRoom / ammoWeightInfo[amTyp])
		ammoWeight += calc_Weight(amTyp, ammountAccepted)
		super.giveAmmo(amTyp, ammountAccepted)
		
		print("Could not take ", amount, " rounds from box only was able to fit ", ammountAccepted)
		
		result = amount - ammountAccepted
	
	if(weapType == 1): #check and see if we should update the UI
		if(activeItem.ourDataSheet.chambering == amTyp):
			uiInfo.updateReserve(chkAmmoAmt(amTyp))
	return result
##Withdraws ammo from invenmanager and updates weight
func withdrawAmmo(amTyp: int, amount: int)-> int:
	var result = super.withdrawAmmo(amTyp, amount)
	recalc_Weight()
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
	var orig = user.playerCam.global_position#project_ray_origin(get_viewport().size / 2)
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

func get_Speed()->Vector3:
	return user.playerVelocity
