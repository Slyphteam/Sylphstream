class_name CONSUMEBEHAVIOR extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func activate(manager: INVENMANAGER, ourItem:INVENITEMPARENT) ->bool: ##returns success or fail
	print("this is the custom consumable behavior parent script, hello!")
	return true
