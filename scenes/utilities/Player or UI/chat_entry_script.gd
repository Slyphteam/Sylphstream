extends Panel
@onready var textHolder = $chatContents
var lines:int = 1 #are we a single or double line?
func receiveText(theText:String):
	if(theText.length() > 54):
		custom_minimum_size.x = 40 #make it a double-line
		lines = 2
	textHolder.text = theText
