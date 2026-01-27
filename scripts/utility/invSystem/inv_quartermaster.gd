##Script that handles drag and drop functionality, built off inv_slot_test
##This script does NOT do a lot of functionality. 
##It is mainly the bridge between the INVENMANAGER data arrays and the GUI. 
extends PanelContainer
@export var invenManager: PLAYERINVENMANAGER
#@onready var weapSlotGrid = $VBoxContainer/WeapGrid
@onready var genericSlotGrid = $VBoxContainer/Row1/genericsPane/GridContainer

##Ammo management stuff:
@onready var weightLabel = $VBoxContainer/TotalWeight

@onready var rimfireLabel = $VBoxContainer/HBoxContainer/ammos1/rimfire
@onready var rimfireSlider = $VBoxContainer/HBoxContainer/sliders1/rimfireSl
@onready var pistolLabel =$VBoxContainer/HBoxContainer/ammos1/pistol
@onready var pistolSlider =$VBoxContainer/HBoxContainer/sliders1/pistolSl
@onready var magnumLabel =$VBoxContainer/HBoxContainer/ammos1/magnum
@onready var magnumSlider =$VBoxContainer/HBoxContainer/sliders1/magnumSl
@onready var rifleLabel =$VBoxContainer/HBoxContainer/ammos2/rifle
@onready var rifleSlider =$VBoxContainer/HBoxContainer/sliders2/rifleSl
@onready var shotgunLabel =$VBoxContainer/HBoxContainer/ammos2/shotgun
@onready var shotgunSlider =$VBoxContainer/HBoxContainer/sliders2/shotgunSl
@onready var heavyLabel =$VBoxContainer/HBoxContainer/ammos2/heavy
@onready var heavySlider =$VBoxContainer/HBoxContainer/sliders2/heavySl

#@export var emptySlot: Texture2D
var currentlyOpen:bool
var heldInvDat: INVENITEMPARENT ##item data that is being dragged
var heldInvIndex:Vector2i ##slotInd, order in slotInd
var wepSlotMaxes:Array
var wepSlotRefs: Array ##Array referencing all the vboxes for each customizable slot
var prevSlotTyp: String ##Previous type of slot we pulled from. useful in indexing into the right invenmanager array

func _ready():
	wepSlotRefs.append($VBoxContainer/Row1/WeaponPane/HBoxContainer/Slot1)
	wepSlotRefs.append($VBoxContainer/Row1/WeaponPane/HBoxContainer/Slot2)
	wepSlotRefs.append($VBoxContainer/Row1/WeaponPane/HBoxContainer/Slot3)
	wepSlotRefs.append($VBoxContainer/Row1/WeaponPane/HBoxContainer/Slot4)
	populate_Inven_Data()

#populates inventory slots according to invenmanager
func populate_Inven_Data():
	wepSlotMaxes = invenManager.slotMaxes
	
	for x in range(1,wepSlotMaxes.size()):
		#var tempSlotArr = invenManager.allSlots[x] 
		#Populate with empty
		for y1 in range(0, wepSlotMaxes[x]):
			var newSlot = preload("res://scenes/utilities/Player or UI/invSlot.tscn").instantiate()
			newSlot.slotInd = x-1
			newSlot.slotTyp = "WEP"
			wepSlotRefs[x-1].add_child(newSlot)
	
	for x in range(0, invenManager.genericItems.size()):
		var newSlot = preload("res://scenes/utilities/Player or UI/invSlot.tscn").instantiate()
		#newSlot.slotInd 
		newSlot.slotTyp = "GEN"
		genericSlotGrid.add_child(newSlot)
	

##Refreshes all display portions of inventory UI
func update_Inven_Data():
	#Do weapons
	for x in range(1,wepSlotMaxes.size()):
		#print("Slot ", x)
		var tempSlotArr = invenManager.allSlots[x] ##Invenmanager's info
		var currentEntries = wepSlotRefs[x-1].get_children() ##Index into the gui slot info
		
		for y in range(0, wepSlotMaxes[x]):
			currentEntries[y].curItem = null
			currentEntries[y].update_info()
		
		for y2 in range(0, tempSlotArr.size()):
			currentEntries[y2].curItem = tempSlotArr[y2]
			currentEntries[y2].update_info()
	#Do generics
	var ind = 0
	for currentSlot in genericSlotGrid.get_children():
		currentSlot.curItem = invenManager.genericItems[ind]
		currentSlot.update_info()
		ind+=1
	
	#Do ammo section
	invenManager.recalc_Weight()
	#print(invenManager.ammoWeight)
	weightLabel.text = "Current ammo weight: " + str(invenManager.ammoWeight) + "/" + str(invenManager.maxweight)
	
	rimfireLabel.text = "Rimfire: " + str(invenManager.heldAmmunition.ammoRimfire) + " (" + str(invenManager.weight22 * invenManager.heldAmmunition.ammoRimfire) + ")"
	pistolLabel.text = "Pistol: " + str(invenManager.heldAmmunition.ammoPistol) + " (" + str(invenManager.weightpistol * invenManager.heldAmmunition.ammoPistol) + ")"
	magnumLabel.text = "Magnum: " +  str(invenManager.heldAmmunition.ammoMagnum) + " (" + str(invenManager.weightrifle * invenManager.heldAmmunition.ammoMagnum) + ")"
	shotgunLabel.text = "Shotgun: " + str(invenManager.heldAmmunition.ammoShotgun) + " (" + str(invenManager.weightShotgun * invenManager.heldAmmunition.ammoShotgun) + ")"
	rifleLabel.text = "Rifle: " + str(invenManager.heldAmmunition.ammoRifle) + " (" + str(invenManager.weightrifle * invenManager.heldAmmunition.ammoRifle) + ")"
	heavyLabel.text = "30 cal: " + str(invenManager.heldAmmunition.ammoThirtycal) + " (" + str(invenManager.weight30cal * invenManager.heldAmmunition.ammoThirtycal) + ")"
	

func _process(delta)->void:
	if(not currentlyOpen):
		return
	if(not has_node("ItemDrag")): #look for node called itemdrag
		return
	#make itemdrag node, if it exists, follow mouse
	get_node("ItemDrag").global_position = get_viewport().get_mouse_position() - Vector2(30,30)


func _input(event: InputEvent) -> void:
	
	
	if(event.is_action_pressed("ui_click")):
		if(not currentlyOpen):
			return
		#print(get_global_mouse_position())
		#check here for if inventory is even open
		var clickedNode = get_viewport().gui_get_hovered_control()
		if(clickedNode is invenSlot && clickedNode.curItem != null):
			
			var invenItem:INVENITEMPARENT #= invenManager.allSlots[heldInvIndex.x + 1][heldInvIndex.y]
			#var guiItem = wepSlotRefs[heldInvIndex.x].get_children()[heldInvIndex.y].curItem
			
			if(clickedNode.slotTyp == "WEP"): #handle weapon logic
				heldInvIndex.x = clickedNode.slotInd 
				heldInvIndex.y = clickedNode.get_index()
				invenItem = invenManager.allSlots[heldInvIndex.x + 1][heldInvIndex.y]
				#print("Clicked item: ",heldInvIndex)
			elif(clickedNode.slotTyp == "GEN"):
				invenItem = invenManager.genericItems[clickedNode.get_index()]
				heldInvIndex.x = clickedNode.get_index()
				#print(invenItem.itemName)
			else:
				assert(clickedNode.slotTyp == "WEP" && clickedNode.slotTyp == "GEN", 
				"Couldn't figure out where to pull data from when making a dragitem! Check the clickedNode logic?")
				#invenItem = in
			#create drag item. no idea why wed want this to be a unique function that seems poorly thought out
			heldInvDat = invenItem #assign the data
			var itemDrag :TextureRect = TextureRect.new()
			prevSlotTyp = clickedNode.slotTyp
			itemDrag.texture = heldInvDat.itemIcon
			itemDrag.mouse_filter = Control.MOUSE_FILTER_IGNORE
			itemDrag.z_index = 3 #gotta set z index
			itemDrag.name = "ItemDrag"
			#print(itemDrag.stretch_mode )
			itemDrag.stretch_mode = 2 
			add_child(itemDrag)
			#invenManager.allSlots[heldInvIndex.x + 1][heldInvIndex.y] = null
			update_Inven_Data()
	
	if(event.is_action_released("ui_click")):
		if(!has_node("ItemDrag")):
			return
		
		var hovNode = get_viewport().gui_get_hovered_control()
		if(hovNode is invenSlot && hovNode.curItem == null):
			
			##Check the slot compatibility logic
			if(check_Typ_Compatible(hovNode.slotTyp, heldInvDat.itemTyp)):
				
				print(hovNode.slotTyp)
				var withdrawResult
				#logic for weapons
				if(hovNode.slotTyp == "WEP"):
					var eligibleSlots = heldInvDat.weapInfoSheet.selections  #check slot eligibility
					if(eligibleSlots.has(hovNode.slotInd + 2)): #yes, ths +2 is correct here.
						#if(prevSlotTyp == "GEN"): #remove from general storage
						withdrawResult = remove_Contents_From_Inventory(prevSlotTyp,heldInvIndex.x, heldInvIndex.y)
							#withdrawResult = invenManager.genericItems[heldInvIndex.x]
							#invenManager.genericItems[heldInvIndex.x] = null
						#else: #remove from wepslots
						#	withdrawResult = invenManager.remove_Invwep(heldInvIndex.x + 1, heldInvIndex.y)
						assert(withdrawResult == heldInvDat, "Held inven data and removed invweapon were not the same!")
						#update the invenmanager to re-add the object at the new coords
						invenManager.allSlots[hovNode.slotInd + 1][hovNode.get_index()] = withdrawResult
						hovNode.curItem = withdrawResult
				

				if(hovNode.slotTyp == "GEN"): #placing into general storage
					
					withdrawResult = remove_Contents_From_Inventory(prevSlotTyp, heldInvIndex.x, heldInvIndex.y)
					hovNode.curItem = withdrawResult
					invenManager.genericItems[hovNode.get_index()] = withdrawResult
					#test placing things into general
					#if(prevSlotTyp == "WEP"):
						##if((invenManager.currentSlot -2 == heldInvIndex.x) && (invenManager.slotSelection == heldInvIndex.y)):
						##	invenManager.change_To_Slot(1) #swap to hands
						#var withdrawResult = invenManager.remove_Invwep(heldInvIndex.x + 1, heldInvIndex.y)
						#hovNode.curItem = withdrawResult
						#invenManager.genericItems[hovNode.get_index()] = withdrawResult
					#if(prevSlotTyp == "GEN"):
						#withdrawResult = invenManager.genericItems[heldInvIndex.x]
						#invenManager.genericItems[heldInvIndex.x] = null
						#
						#hovNode.curItem = withdrawResult
						#invenManager.genericItems[hovNode.get_index()] = withdrawResult
						#
	
			#whatever we have, we're dropping
				if(hovNode.slotTyp == "DROP"):
					withdrawResult = remove_Contents_From_Inventory(prevSlotTyp, heldInvIndex.x, heldInvIndex.y)
					#if(prevSlotTyp == "WEP"): #dropping from weapons
						#withdrawResult = invenManager.remove_Invwep(heldInvIndex.x + 1, heldInvIndex.y)
					#if(prevSlotTyp == "GEN"): #dropping from general
						#withdrawResult = invenManager.genericItems[heldInvIndex.x]
						#invenManager.genericItems[heldInvIndex.x] = null
					
					assert(withdrawResult.itemEntScene, "Tried to drop a weapon that didn't know its own entity scene!!")
					var droppedItem = load(withdrawResult.itemEntScene).instantiate()
					#put it at the player
					droppedItem.position = invenManager.get_Origin()
					#and a little in front of them
					droppedItem.position += (Vector3.FORWARD * 2).rotated(Vector3.UP, invenManager.get_Rotation().y)
					Globalscript.theTree.root.add_child(droppedItem)
					
		#no matter what happens, clean up itemDrag if the mouse is released
		get_node("ItemDrag").queue_free()
		heldInvDat = null
		update_Inven_Data()
	
	#let's allow players to "consume" items from the inventory panel
	if(event.is_action_pressed("ui_interact")):
		if(not currentlyOpen):
			return
		var clickedNode = get_viewport().gui_get_hovered_control()
		if(clickedNode is invenSlot && clickedNode.curItem != null && clickedNode.slotTyp != "WEP"):
			var insideItem = clickedNode.curItem
			
			var consumeResult = invenManager.consume_item(insideItem)
			print(consumeResult)
			if(consumeResult == true):
				remove_Contents_From_Inventory("GEN", clickedNode.get_index(), 0)
				update_Inven_Data()
			

func remove_Contents_From_Inventory(typ, xInd, yInd)->INVENITEMPARENT:
	#if(!theNode.curItem):
	#	return null
	#theNode.curItem = 
	
	var result
	if(typ == "WEP"):
		result =  invenManager.remove_Invwep(xInd + 1, yInd)
#		theNode.curItem = null
	
	
	if(typ == "GEN"):
		result = invenManager.genericItems[xInd]
		invenManager.genericItems[xInd] = null
	return result

##Returns whether typItem can be inserted into typSlot.
func check_Typ_Compatible(typSlot, typItem):
	if(typSlot == prevSlotTyp): #we're putting into a slot from the same type, yeah, they're gonna be compatible
		return true
	if(typSlot == "DROP"): #can always put into drop slots
		return true
	if(typSlot == "GEN"): #can always put into general slots
		return true
	if(typSlot == typItem): #the slot and the item match up
		return true

	return false
