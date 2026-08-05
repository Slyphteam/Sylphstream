class_name CUSTOMBEHAVIOR extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func activate(manager: INVENMANAGER, ourItem:INVENITEMPARENT) ->bool:
	print("this is the custom consumable behavior parent script, hello!")
