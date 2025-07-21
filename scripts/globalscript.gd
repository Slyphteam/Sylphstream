extends Node
var datapanel
var timer : float ##Global timer.
var isPlaying = false ##Is the game paused or running?
var thePlayer
var allSylphs: Array

func _process(delta):
	timer += delta 

##Same weighted probability from layer script. Takes input 0-1, returns chance of 1-99
func weighted_Prob(chance)->bool:
	chance = absf(chance) #Can take negative inputs
	#Rather than going from 0-100% on 0-1, instead fo from 1-99. Therefore, the range is
	#actually 0-98 + 1
	var val = int(chance * 98) + 1
	var targ = randi_range(0, 100)
	if(val >= targ):
		return true
	
	return false

func add_Sylph(newSylph):
	allSylphs.resize(allSylphs.size() + 1)
	allSylphs[allSylphs.size() - 1] = newSylph


#Handle Meta UI here
func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event): 
	if event.is_action_pressed("ui_cancel"):
		togglePaused()

func togglePaused():
	if(Globalscript.isPlaying):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Globalscript.isPlaying = false
		thePlayer.uiInfo.pauseMenu.visible = true
		get_tree().paused = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Globalscript.isPlaying = true
		thePlayer.uiInfo.pauseMenu.visible = false
		get_tree().paused = false
