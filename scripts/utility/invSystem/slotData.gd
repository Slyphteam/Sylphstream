class_name invenSlot extends TextureRect
@export var curItem:INVENITEMPARENT
var defIcon: Texture2D# var defTexture

func _ready() -> void:
	defIcon = texture
	update_info()

func update_info():
	if(curItem):
		texture = curItem.itemIcon
	else:
		texture = defIcon
	
