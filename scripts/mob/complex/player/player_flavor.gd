## PLAYER CAMERA
# Manages bobbing, tilt, minor camera adjustments
extends Camera3D

#For new zoom: dot product of players lookdir and speed


var theta:float = 0 #our counter

# export variables
@export var bob_speed_target : float = 0.0
@export var tilt_amount_target : float = 0.0
@export var bob_intensity : float = 3.0
@export var lerp_val : float = 0.1

var playerSpd:float

# internal variables
var bob_time : float = 0.0
var bob_speed : float = 0.0
var tilt_amount : float = 0.0 # negative is to the left, positive is to the right


#footstep variables
@onready var ourPlayer = $"../.."
@onready var debugText = $"../../Player UI/debugText"
@export var footstepDelay = 0.5 ##fractional multiplier to slow down the theta counter that determines footstep times
@export var bobIntensity:float = 0.5 ##how much do we bob along with the footsteps?
var previousSign: int = 1
var played = false
var ourSounds:Array = ["res://sounds/footsteps/concrete/fsConcLoud4.mp3", 
"res://sounds/footsteps/concrete/fsConcQuiet1.mp3", "res://sounds/footsteps/concrete/fsConcQuiet2.mp3", 
"res://sounds/footsteps/concrete/fsConcQuiet4.mp3", "res://sounds/footsteps/concrete/fsConcQuiet6.mp3"]
#"res://sounds/footsteps/concrete/fsConcQuiet3.mp3"]



func _process(delta):
	handleBob(delta)
	
	playerSpd = ourPlayer.playerSpeed
	
	if(playerSpd <= 0.01): #don't update
		playerSpd = 0
	
	
	
	theta += delta * playerSpd * footstepDelay
	
	if(check_Player_Step_Eligible()):
		
		#print(theta)
		do_Steps(theta, delta)
	
	if(theta >= 2 * PI):
		theta -= 2 * PI
	
	
func check_Player_Step_Eligible()-> bool:
	if(playerSpd == 0):
		return false
	if(ourPlayer.crouchSliding):
		return false
	if(!ourPlayer.is_on_floor()): #probably could simplify here but ehhhhh
		return false
	
	return true

func do_Steps(theta, delta):
	
	var progression = sin(theta)
	var bajookie = previousSign * bobIntensity * progression
	debugText.text = str(bajookie)
	#self.position.y -= bajookie
	#debugText.text=str(self.position.y)
	if(progression < 0 && previousSign == 1): #inflection to negative
		do_Stepsound()
		previousSign = -1
	if(progression > 0 && previousSign == -1):
		do_Stepsound()
		previousSign = 1
		
	#print(progression)
	#if(progression > -0.01 && progression < 0.01):
		#if(!played):
		
		#	played = true
	#poll our player state to see if steps are even something we should be thinking about handling
	

func do_Stepsound():
	var stepPlay = AudioStreamPlayer.new()
	stepPlay.stream = AudioStreamMP3.load_from_file(ourSounds.pick_random())
	stepPlay.volume_db = -7
	add_child(stepPlay)
	stepPlay.playing = true
	
	await stepPlay.finished
	stepPlay.queue_free()
	

##VERY simple function that applies an extremely subtle viewbob. doesnt do anything else, just bobs the view, doesnt do footstep bob, either.
func handleBob(delta):
	# set values based on player stats
	
	
#	
#		print(int(player.playerSpeed / 5))
	
	#clamp bobspeed between 1(slow) and 3(fast)
	bob_speed_target = clampf(ourPlayer.playerSpeed / 5.0, 1.0, 4)
	bob_intensity = max(ourPlayer.playerSpeed / 500.0, 0.01)
	
	bob_speed = lerp(bob_speed, bob_speed_target, lerp_val)
	bob_time += delta * bob_speed
	#bob_time = Globalscript.timer * bob_speed
	var bob_offset = bob_intensity * sin(bob_time)
	position.y = bob_offset

#delta was unused so I commented it out
func handleTilt(): #delta):
	# set values based on player stats
	var sideways_vel = ourPlayer.playerVelocity.dot(ourPlayer.basis.x)  # get sideways velocity
	
	# normal sideways movement
	tilt_amount_target = sideways_vel / 5.0
	
	# croushsliding override
	if ourPlayer.crouchSliding:
		if abs(sideways_vel) < 10.0:
			tilt_amount_target = 10.0
		else:
			tilt_amount_target = sideways_vel / 2.0
	
	tilt_amount = lerp(tilt_amount, tilt_amount_target, lerp_val)
	
	rotation.z = - tilt_amount / 100.0 # tweak these values to your hearts content
