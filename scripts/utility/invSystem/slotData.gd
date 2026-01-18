class_name invenSlot extends TextureRect
@export var curItem:INVENITEMPARENT
var defIcon: Texture2D# var defTexture
@export var slotTyp:String #"WEP", ...
var slotInd:int  = -1 ##For weapon slots: which do we belong to, if any?

func _ready() -> void:
	defIcon = texture
	update_info()

func update_info():
	if(curItem):
		texture = curItem.itemIcon
		#print("Item received: ",curItem.itemName)
	else:
		texture = defIcon
	
