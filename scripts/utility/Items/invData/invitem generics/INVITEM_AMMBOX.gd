class_name INVAMMBOX extends INVENITEMPARENT
@export var arrLength:int #how many type/amount pairs do we have
#this is deprecated since we're using scripts for weird edge cases
#@export var typeArr:Array[int] ##arrays specifying the types
#@export var amtArr:Array[int] ##Arrays specifying the amounts
@export var ammoType:int


func _init():
	itemHint = "Press E to consume \nSecondary click with HANDS to phys drag"
