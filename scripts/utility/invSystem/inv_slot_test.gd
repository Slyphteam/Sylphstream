##Test script for grid-based inventory system. this should be SUPER temporary
extends Panel
@export var managerAcc: PLAYERINVENMANAGER
var curDraggedDat: INVENITEMPARENT ##item data that is being dragged
@onready var ourGrid = $GridContainer
var currIndex:int ##Index we have dragged an item from, in case we can't put it back
##honorable mention: itemdrag, a texture 2d which only exists when we are dragging that just
#follows the mouse

func _process(delta)->void:
	return
	if(not has_node("ItemDrag")): #look for node called itemdrag
		return
	#make itemdrag node, if it exists, follow mouse
	get_node("ItemDrag").global_position = get_global_mouse_position() - get_node("ItemDrag").size /2


##called when we open inventory, called when we change inventory. Expensive?
func update_Inven_Data():
	return
	
	#purge inventory
	for slot in ourGrid.get_children():
		slot.queue_free()
	
	#populate from invenmanager's information
	for loadItem in managerAcc.itemsTest:
		#create new slot
		var newSlot = preload("res://scripts/utility/invSystem/invSlot.tscn").instantiate()
		newSlot.curItem = loadItem
		ourGrid.add_child(newSlot)

func _input(event: InputEvent) -> void:
	return
	if(event.is_action_pressed("ui_click")):
		#print(get_global_mouse_position())
		#check here for if inventory is even open
		var clickedNode = get_viewport().gui_get_hovered_control()
		if(clickedNode is invenSlot):
			currIndex = clickedNode.get_index() #get order assigned by the grid controller
			if(managerAcc.itemsTest[currIndex] != null):
				make_Drag_Item(managerAcc.itemsTest[currIndex]) #make it into a drag item
				managerAcc.itemsTest[currIndex] = null #remove from inventory
				update_Inven_Data()
				
	if(event.is_action_released("ui_click")):
		if(has_node("ItemDrag")):
			var hovNode = get_viewport().gui_get_hovered_control()
			if(hovNode is invenSlot):
				var hovInd = hovNode.get_index()
				if(managerAcc.itemsTest[hovInd] == null):
					managerAcc.itemsTest[hovInd] = curDraggedDat
				else: #abort procedure
					managerAcc.itemsTest[currIndex] = curDraggedDat
				#delete dragitem
				get_node("ItemDrag").queue_free()
				curDraggedDat = null
				currIndex = -1
				update_Inven_Data()
			else: #also delete it
				managerAcc.itemsTest[currIndex] = curDraggedDat
				get_node("ItemDrag").queue_free()
				curDraggedDat = null
				currIndex = -1
				update_Inven_Data()

func make_Drag_Item(thingy:INVENITEMPARENT):
	return
	curDraggedDat = thingy #assign the data
	var itemDrag :TextureRect = TextureRect.new()
	itemDrag.texture = curDraggedDat.itemIcon
	itemDrag.mouse_filter = Control.MOUSE_FILTER_IGNORE
	itemDrag.z_index = 3 #gotta set z index
	itemDrag.name = "ItemDrag"
	add_child(itemDrag)
	
