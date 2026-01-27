class_name INVAMMBOX extends INVENITEMPARENT
@export var arrLength:int #how many type/amount pairs do we have
@export var typeArr:Array[int] ##arrays specifying the t ypes
@export var amtArr:Array[int] ##Arrays specifying the amounts

func _init():
	itemHint = "Press E to consume \nSecondary click with HANDS to phys drag"
