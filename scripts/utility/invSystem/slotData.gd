extends TextureRect
@export var curItem:INVENITEMPARENT
@onready var ourIcon:TextureRect

func _ready() -> void:
	update_info()

func update_info():
	if(curItem== null):
		return
	ourIcon.texture = curItem.itemIcon
	
