##Parent class for an item that is held in an inventory slot. Represents an item in INVENTORY, use WEAPOINFO for item represented in HANDS.
class_name INVENITEMPARENT extends Resource
@export var itemName:String = "Generic Item Name"
@export var itemDesc:String = "Generic Description"
@export var itemHint: String = ""
@export var itemIcon:Texture2D 
@export var itemEntScene:String
@export var itemFlags:Array = []
@export var itemTyp = "GEN"
