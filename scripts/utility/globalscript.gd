extends Node
var datapanel
var timer : float ##Global timer.
var isPlaying = false ##Is the game paused or running?
var thePlayer
var allSylphs: Array
var activeSylphs: Array
var theTree

var deltaButNotStinky = 0 ##copy of delta that's scaled by 60 to use as a unit

func _ready():
	theTree = get_tree()
	#print(theRoot)

func _process(delta):
	deltaButNotStinky = delta * 60
	timer += delta 

# I suspect the randf function in godot uses noise to populate a float, i.e.,
#mantissa encoding gives it a logarithmic skew. (future me note: oh it definitely does)
#Therefore it's absolutely worth making a better randf
##Desired length of the number portion, desired length of the zeros padding number
func better_Randf_Simple(digits, decimalZeros, divBy)-> float:
	var ourMax = 1 
	for x in range(digits):
		ourMax *= 10
	
	var result:float = randi_range(0-ourMax, ourMax)
	for x in range(digits + decimalZeros):
		result/=10
	
	
	result /=divBy
	return result

#func better_Randf_Clamped(digits, numZeros, max, min)->float: 
##Returns true/false based on a % chance
func prob(chance:int)->bool:
	chance = abs(chance) #Can take negative inputs

	var targ = randi_range(0, 100)
	if(chance >= targ):
		return true
	
	return false

##Adds a sylph to the ALL sylphs tracking array.
func add_Sylph(newSylph):
	allSylphs.resize(allSylphs.size() + 1)
	allSylphs[allSylphs.size() - 1] = newSylph

##Enrolls a sylph in the tracking array for training
func enroll_Sylph(newSylph):
	activeSylphs.resize(activeSylphs.size() + 1)
	activeSylphs[activeSylphs.size() - 1] = newSylph
#Handle Meta UI here
func _init():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event): 
	if event.is_action_pressed("ui_cancel"):
		togglePaused()

func togglePaused():
	if(Globalscript.isPlaying):
		if(thePlayer.uiInfo.invContain.visible):
			thePlayer.uiInfo.toggle_Inv()
			
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		Globalscript.isPlaying = false
		thePlayer.uiInfo.pauseMenu.visible = true
		get_tree().paused = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		Globalscript.isPlaying = true
		thePlayer.uiInfo.pauseMenu.visible = false
		get_tree().paused = false

##"Raises" a custom exception by printing a message and then divding by zero
func raise_Panic_Exception(exceptionMessage:String):
	print(exceptionMessage)
	
	var crashMaker = 0
	@warning_ignore("integer_division") print(42/crashMaker)


var playerCasings:Array
var maxCasings:int = 100



func push_Casing(theCasing, isPlayer):
	if(!isPlayer):
		await theTree.create_timer(10).timeout
		theCasing.queue_free()
	playerCasings.push_back(theCasing)
	if(playerCasings.size() > maxCasings):
		playerCasings.pop_front().queue_free()
