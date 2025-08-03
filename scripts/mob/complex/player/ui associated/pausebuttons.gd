extends Button
func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _pressed():
	Globalscript.togglePaused()
