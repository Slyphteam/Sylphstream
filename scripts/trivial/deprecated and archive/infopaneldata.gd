##This is a DEPRECATED script that used to manage the player's datapanel. 
#Since a UI now gives the player this info and this script was never not buggy, it's
#now deprecated and in the deprecated bin.
extends PanelContainer
@onready var propertyContainer = $VBoxContainer
 
func _ready():
	Globalscript.datapanel = self
	add_Property("testy","test", 0)

#var newprop
func add_Property (title: String, value, order):
	return
	#var propCheck = propertyContainer.find_child(title,true,false)
	#if(not propCheck):
		##print("Adding new property!")
		#propCheck = Label.new()
		#propertyContainer.add_child(propCheck)
		#propCheck.name = title
		#propCheck.text = title  + ": "+ str(value)
	#else:
		#propCheck.text = title  + ": "+ str(value)
		#propertyContainer.move_child(propCheck, order)
		
