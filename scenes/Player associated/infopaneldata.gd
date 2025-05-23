extends PanelContainer
@onready var propertyContainer = $VBoxContainer

func _ready():
	Globalscript.datapanel = self
	add_Property("test","test")
	
var newprop
func add_Property (title: String, value):
	newprop = Label.new()
	propertyContainer.add_child(newprop)
	newprop.name = title
	newprop.text = title + value
	
