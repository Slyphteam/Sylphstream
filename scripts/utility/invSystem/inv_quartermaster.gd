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

#Refreshes the inven icons with new data
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
	get_node("ItemDrag").global_position = get_global_mouse_position() - get_node("ItemDrag").size /2


func _input(event: InputEvent) -> void:
	if(not currentlyOpen):
		return
	
	if(event.is_action_pressed("ui_click")):
		return
		#print(get_global_mouse_position())
		#check here for if inventory is even open
		var clickedNode = get_viewport().gui_get_hovered_control()
		if(clickedNode is invenSlot):
			
			if(clickedNode.curItem == null):
				return
			
			if(clickedNode.slotTyp == "WEP"): #handle weapon logic
				print("bazinga")
		
		##Half working old code
			heldInvIndex.x = clickedNode.slotInd #Get the slot we're in, TODO UNTESTED
			heldInvIndex.y = clickedNode.get_index()
			print("Clicked item: ",heldInvIndex)
			#currIndex = clickedNode.get_index() #get order assigned by the grid controller
			#this next part relies on the inventories and gui having same data, which should always happen,
			#but I'm still iffy on trusting like that
			
			#curse me and my dynamic ass arrays
			if(invenManager.allSlots[heldInvIndex.x + 1].size() < heldInvIndex.y+1 ):
				#we can't index into the array, abort
				return
				#print("wuh oh")
			var invenItem = invenManager.allSlots[heldInvIndex.x + 1][heldInvIndex.y]
			var guiItem = wepSlotRefs[heldInvIndex.x].get_children()[heldInvIndex.y].curItem
			if(invenItem != guiItem):
				Globalscript.raise_Panic_Exception("Attempted to click-and-drag from inventory with INCONSISTENT data!!!")
			
			#in theory there should never be a null in either because null values would mean
			#we cant index into the invenmanager array, handled above, but because I want to, fuck it
			if(invenItem == null || guiItem == null):#due to prev this means they both must be
				return
			
			#create drag item. no idea why wed want this to be a unique function that seems poorly thought out
			heldInvDat = invenItem #assign the data
			var itemDrag :TextureRect = TextureRect.new()
			itemDrag.texture = heldInvDat.itemIcon
			itemDrag.mouse_filter = Control.MOUSE_FILTER_IGNORE
			itemDrag.z_index = 3 #gotta set z index
			itemDrag.name = "ItemDrag"
			add_child(itemDrag)
			invenManager.allSlots[heldInvIndex.x + 1][heldInvIndex.y] = null
			update_Inven_Data()
			
	
	##Old old stuff
	#if(event.is_action_released("ui_click")):
		#if(has_node("ItemDrag")):
			#var hovNode = get_viewport().gui_get_hovered_control()
			#if(hovNode is invenSlot):
				#var hovInd = hovNode.get_index()
				#if(managerAcc.itemsTest[hovInd] == null):
					#managerAcc.itemsTest[hovInd] = curDraggedDat
				#else: #abort procedure
					#managerAcc.itemsTest[currIndex] = curDraggedDat
				##delete dragitem
				#get_node("ItemDrag").queue_free()
				#curDraggedDat = null
				#currIndex = -1
				#update_Inven_Data()
			#else: #also delete it
				#managerAcc.itemsTest[currIndex] = curDraggedDat
				#get_node("ItemDrag").queue_free()
				#curDraggedDat = null
				#currIndex = -1
				#update_Inven_Data()

#func make_Drag_Item(thingy:INVENITEMPARENT):
	
	
