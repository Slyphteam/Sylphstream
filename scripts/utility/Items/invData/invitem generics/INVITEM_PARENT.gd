##Parent class for an item that is held in an inventory slot. 
#Represents an item in INVENTORY, use WEAPOINFO for item represented in HANDS.
class_name INVENITEMPARENT extends Resource
@export var itemName:String = "Generic Item Name"
@export var itemDesc:String = "Generic Description"
@export var itemHint: String = "Press E to use. Press ALT to pick up without using."
@export var itemIcon:Texture2D 
@export var itemEntScene:String
@export var extraData:Array[int] = [] ##Array of extra data, used differently depending on consume script
@export var amount:int = 1 #how many things of stuff do we have?
@export var maxStack:int = 1 #what's the highest we can stack?
@export var itemTyp = "GEN"
@export var doConsumeScript:bool = false
@export var consumeScript:String
