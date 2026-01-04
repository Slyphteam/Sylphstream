##Script that handles drag and drop functionality, built off inv_slot_test
##This script does NOT do a lot of functionality. 
##It is mainly the bridge between the INVENMANAGER data arrays and the GUI. 
extends PanelContainer
@export var invenManager: PLAYERINVENMANAGER
@onready var weapSlotGrid = $VBoxContainer/WeaponSlots/WeapGrid
#@export var emptySlot: Texture2D
var currentlyOpen:bool
var heldInvDat: INVENITEMPARENT ##item data that is being dragged
var heldInvIndex:Vector2i ##slotInd, order in slotInd
var wepSlotMaxes:Array
var wepSlotRefs: Array ##Array referencing all the vboxes for each customizable slot

func _ready():
	wepSlotRefs.append($VBoxContainer/WeaponSlots/WeapGrid/Slot1)
	wepSlotRefs.append($VBoxContainer/WeaponSlots/WeapGrid/Slot2)
	wepSlotRefs.append($VBoxContainer/WeaponSlots/WeapGrid/Slot3)
	wepSlotRefs.append($VBoxContainer/WeaponSlots/WeapGrid/Slot4)
	populate_Inven_Data()

#populates inventory slots according to invenmanager
func populate_Inven_Data():
	wepSlotMaxes = invenManager.slotMaxes
	
	for x in range(1,wepSlotMaxes.size()):
		var tempSlotArr = invenManager.allSlots[x] 
		#Populate with empty
		for y1 in range(0, wepSlotMaxes[x]):
			var newSlot = preload("res://scripts/utility/invSystem/invSlot.tscn").instantiate()
			newSlot.slotInd = x-1
			newSlot.slotTyp = "WEP"
			wepSlotRefs[x-1].add_child(newSlot)

##Refreshes the inven icons with new data from invenmanager
func update_Inven_Data():
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
				heldInvIndex.x = clickedNode.slotInd #Get the slot we're in, TODO UNTESTED
				heldInvIndex.y = clickedNode.get_index()
				invenItem = invenManager.allSlots[heldInvIndex.x + 1][heldInvIndex.y]
				#print("Clicked item: ",heldInvIndex)
				
			#create drag item. no idea why wed want this to be a unique function that seems poorly thought out
			heldInvDat = invenItem #assign the data
			var itemDrag :TextureRect = TextureRect.new()
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
			if(check_Typ_Compatible(hovNode.slotTyp, heldInvDat.itemTyp)):
				
				#logic for weapons
				if(hovNode.slotTyp == "WEP"):
					#check slot eligibility
					var eligibleSlots = heldInvDat.weapInfoSheet.selections  #check slot eligibility
					if(eligibleSlots.has(hovNode.slotInd + 2)): #yes, ths +2 is correct here.
						var result = invenManager.remove_Invwep(heldInvIndex.x + 1, heldInvIndex.y)
						if(result != heldInvDat):
							Globalscript.raise_Panic_Exception("Held inven data and removed invweapon were not the same!")
						#update the invenmanager to re-add the object at the new coords
						invenManager.allSlots[hovNode.slotInd + 1][hovNode.get_index()] = result
						hovNode.curItem = result
				
		#no matter what happens, clean up itemDrag if the mouse is released
		get_node("ItemDrag").queue_free()
		heldInvDat = null
		update_Inven_Data()

##Returns whether typItem can be inserted into typSlot.
func check_Typ_Compatible(typSlot, typItem):
	if(typSlot == typItem):
		return true
	if(typSlot == "GEN"):
		return true
	return false
