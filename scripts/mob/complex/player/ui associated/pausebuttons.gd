extends Button
func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _pressed():
	Globalscript.togglePaused()
	#if(get_tree().paused):
		#get_tree().paused = false
	
	#if(Globalscript.thePlayer.uiInfo.pauseMenu.visible):
		#Globalscript.thePlayer.uiInfo.pauseMenu.visible = false
	#
	#
	
	#Globalscript.thePlayer.uiInfo.pauseMenu.visible = false
	#Globalscript.togglePaused()
	
	#get_tree().paused = false
