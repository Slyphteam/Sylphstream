#extends  "res://playershared.gd"
extends CharacterBody3D

const sourcelike = true
const gravAmount = 60

#player camera variables
var ylook : float
var xlook : float
var mousesensitivity = 0.3
var ply_maxlookangle_down = -90
var ply_maxlookangle_up = 90
var ply_ylookspeed = 0.3
var ply_xlookspeed = 0.3

#player input/movement variables
const maxIn = 4096 #boundaries for the most "walking" we want to be doing
const minIn = -4096
var leftright : float #variables for how "walking" we are in either cardinal direction
var forback : float
var playerVelocity: Vector3 = Vector3.ZERO
var onFloor = false
const maxvelocity = 100; #this might not seem insane but keep in mind 20 is walking speed

#crouching/jumping variables
var touchingFloor = true
var crouching = false
var canjump = true
var jumpheight = 4


# these affect the "slipperiness" of the player
const debugging = true
const walkMod = 10 # 10 responsiveness
const friction = 3 # 3 stopping speed, if passes threshhold, bad things happen
const stopspeed = 50 # 50 equal to around 4 units of speed loss per tick with 3 friction
const accelerateamount = 7 #7 used in dosourcelikeaccelerate #WHY WAS THIS A THOUSAND??? HUH??????
const maxspeed = 16 #16 used in player velocity calculations as a clamp - handlefloorsourcelike

@onready var playerCam = $came
@onready var playerShape = $shape


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		InputMouse(event)
		
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event.is_action_pressed("ui_click"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

			
	#if Input.is_action_pressed("in_crouch"):
		#crouching = true
	#elif Input.is_action_just_released("in_crouch"):
		#crouching = false
		
func InputMouse(event):
	xlook += -event.relative.y * mousesensitivity
	ylook += -event.relative.x * mousesensitivity
	
	
	xlook = clamp(xlook, -90, 90)
	
func ViewAngles():
	playerCam.rotation_degrees.x = xlook
	playerCam.rotation_degrees.y = ylook

# handle wasd inputs
# will listen to keypresses and update the movement variables above
#mouse movement is handled by _input
func getInputs():
	var bonus = 1 # formerly 1
	
	#okay, let's talk about movement. 
	# presently, 20 feels like good running. 
	# this is determined by walkMod?
	
	
	leftright += int(walkMod) * (int(Input.get_action_strength("ui_left") * bonus)) 
	leftright -= int(walkMod) * (int(Input.get_action_strength("ui_right") * bonus)) 
	
	forback += int(walkMod) * (int(Input.get_action_strength("ui_up") * bonus))
	forback -= int(walkMod) * (int(Input.get_action_strength("ui_down") * bonus))
	
	# clamp left/right movement
	if Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		leftright = 0
	else:
		leftright = clamp(leftright, minIn, maxIn) 
	#clamp forwards/backwards input
	if Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_down"):
		forback = 0
	else:
		forback = clamp(forback, minIn, maxIn)
	

var prevBob = 0;
var bobOffset = 0;
func _physics_process(delta: float) -> void:
	getInputs()
		
	
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		ViewAngles()
	
		
	handleMove(delta)
	checkVelocityAndMove()
	
	#Adjust FOV. 87 feels the best; 85 too low and 90 too high
	playerCam.fov = clamp(87 + sqrt(playerVelocity.length()), 90, 180) 
	
	#create viewbob
	bob_time += delta * float(is_on_floor())
	bobOffset = doHeadBob(bob_time, prevBob) # this needs more tweaking but it's fine for now
	playerCam.transform.origin.y = bobOffset+1.75
	prevBob = bobOffset

const bobAmplitude = 0.05
const bobFreq = 2
var bob_time = 0
func doHeadBob(time, prev)->float:
	var pos = Vector3.ZERO
	#var velocityMult = 1
	var playerSpeed = playerVelocity.length()
	
	#create a ratio that's dependent on playerspeed. 
	#rougly between 1 and 1.5
	var newRatio =  1 + (playerSpeed / (maxspeed * 2 ))
	#if(newRatio > 1):
	#	print("Ratio: ", newRatio)
		
	var new_freq = bobFreq *  newRatio #apply ratio to frequency
	var new_amplitude = bobAmplitude * newRatio # bump up the amplitude
	
	var newOffset = sin(time * new_freq) * new_amplitude #plug in cam_Freq if you want to get experimental
	
	# even though we really aren't applying an insane amount, still weight the offset to the previous
	# in order to prevent jitteriness from sudden changes
	newOffset = (newOffset +(3*prev))/4 
	#if(cam_freq > bobFreqDef):
		#print("Bob difference: ", prev, " : ", newOffset)
	return newOffset


func handleMove(delta):
	if (is_on_floor()):
		
		#this does a SHOCKINGLY good job at emulating source bunnyhopping
		if (not canjump):
			if(not Input.is_action_pressed("ui_jump") ): 
				canjump = true
		
		handleFloorSourcelike(delta)
		

		
	else: 
		handleSourcelikeAir(delta)
	
	if Input.is_action_pressed("ui_jump") && canjump:
		if not crouching:
			touchingFloor = false
			canjump = false
			doJump()
	
	if playerVelocity.length() > maxvelocity:
		print("MAX VELOCITY HIT!")
		#playerVelocity = maxvelocity playervelocity is a VECTOR. what???
		#return # this still doesn't reduce the player velocity by a serious amount
		playerVelocity *= 0.5 #this seems to work!


func handleFloorSourcelike(delta):
		#TODO: ADD A TIMER
	
	#alter the forward movement by camera's azimuth rotation. shouldnt do anything yet.
	var forwAngle = (Vector3.FORWARD).rotated(Vector3.UP, playerCam.rotation.y).normalized()
	var sideAngle = (Vector3.LEFT).rotated(Vector3.UP, playerCam.rotation.y).normalized()
	

	
	#calculate a vector based of our inputs and angles
	var desiredVec = (leftright * sideAngle) + (forback * forwAngle)
	
	#deal with friction
	handleFriction(delta)
	
	var desiredDir = desiredVec.normalized()
	var desiredSpeed = desiredVec.length()
	
	#a really funny bug to have happen was zeroing out the desiredvec.y here
	#which meant you could just phase through the floor by trying hard enough. 
	#and also fly.
	
	if desiredSpeed !=0.0 and desiredSpeed>maxspeed:
		desiredVec *= maxspeed / desiredSpeed # update our vector to not be too silly
		desiredSpeed = maxspeed # clamp it
	
	desiredVec.y = 0; #but no y. 
	doSourceAccelerate(desiredDir, desiredSpeed, delta)


func doSourceAccelerate(desiredDir, desiredSpeed, delta):
	
	var currentspeed = playerVelocity.dot(desiredDir) # are we changing direction?
	var addedspeed = desiredSpeed - currentspeed # reduce by amount
	
	if addedspeed <= 0: #no need to do anything
		return
	
	#if debugging:
		#print("accelerating by:", addedspeed)
	var acelspeed = accelerateamount * delta * desiredSpeed
	
	playerVelocity.y -= gravAmount * delta
	
	for i in range(3): #the comment says adjust velocity but i truly have no idea what this does
		playerVelocity+= acelspeed * desiredDir

##################################AIR MOVEMENT

func doJump():
	
	var flGroundFactor = 1.0
	var flMul : float
	
	#trying to emulate that crouch jumping is slightly higher than jump crouching but not completely 
	#accurate. Reasion why you jump higher mid crouch is because the game forgets to apply gravity for 
	#the first frame. This attempts to recreate it by removing one frame of gravity to make up for it
	
	if crouching: 
		flMul = sqrt(2 * gravAmount * jumpheight) + ((1./60.) * gravAmount)
		
	else:
		move_and_collide(Vector3(0, 2-playerShape.scale.y, 0))		
		flMul = sqrt(2 * gravAmount * jumpheight)
	var jumpvel =  flGroundFactor * flMul  + max(0, playerVelocity.y)
	playerVelocity.y = max(jumpvel, jumpvel + playerVelocity.y)

func handleSourcelikeAir(delta):
	if debugging:
		print("in air!")
	var forward = Vector3.FORWARD
	var side = Vector3.LEFT
	
	forward = forward.rotated(Vector3.UP, playerCam.rotation.y).normalized()
	side = side.rotated(Vector3.UP, playerCam.rotation.y).normalized()
	
	playerVelocity.y -= gravAmount * delta
	
	var fmove = forback
	var smove = leftright
	
	var wishvel = side * smove + forward * fmove
	
	# Zero out y value
	wishvel.y = 0
	
	var wishdir = wishvel.normalized()
	# VectorNormalize in the original source code doesn't actually return the length of the normalized vector
	# It returns the length of the vector before it was normalized
	var wishspeed = wishvel.length()
	
	# clamp to game defined max speed
	if wishspeed != 0.0 and wishspeed > maxspeed:
		wishvel *= maxspeed / wishspeed
		wishspeed = maxspeed
	
	doSourceAirAccelerate(wishdir, wishspeed, delta) #let the airaccelerate function do its work


func doSourceAirAccelerate(desiredDir, desiredSpeed, delta):
	var accel = 20 #global airaccelerate 
	desiredSpeed = min(desiredSpeed, 15) # global airspeed cap 
	# See if we are changing direction a bit
	var currentspeed = playerVelocity.dot(desiredDir)
	## Reduce wishspeed by the amount of veer.
	var addspeed = desiredSpeed - currentspeed
	
	if addspeed <= 0: # early return
		return
#
	## Determine amount of accleration.
	var accelspeed = accel * desiredSpeed * delta 
	#
	## Cap at addspeed
	accelspeed = min(accelspeed, addspeed)
	#
	for i in range(3):
		# Adjust velocity.
		playerVelocity += accelspeed * desiredDir

################################ GENERALIZED MOVEMENT

#this is the function that ACTUALLY causes the player to move
func checkVelocityAndMove():
	if playerVelocity.length() > maxvelocity:
		if(debugging): print("MAX VELOCITY HIT!")
		#playerVelocity = maxvelocity playervelocity is a VECTOR. what???
		#return # this still doesn't reduce the player velocity by a serious amount
		playerVelocity *= 0.5 #this seems to work!
	
	if(debugging):
		var speedcheck = playerVelocity.length()
		if(speedcheck > 0):
			print("Velocity:", speedcheck)
		
	velocity = playerVelocity
	move_and_slide()
	playerVelocity = velocity

func handleFriction(delta):
	var speed = playerVelocity.length()
	
	if speed <= 0:
		return
	
	var control = stopspeed if speed < stopspeed else speed
	# Add the amount to the drop amount.
	var drop = control * friction * delta

	# scale the velocity
	var newspeed = speed - drop
	if newspeed < 0:
		newspeed = 0
	
	if newspeed != speed:
		# Determine proportion of old speed we are using.
		newspeed /= speed
		# Adjust velocity according to proportion.
		playerVelocity *= newspeed
		
		#if(debugging):
			#var speedcheck = playerVelocity.length()
			#print("Old/hampered velocity:", speedcheck, " : ", playerVelocity.length())


func move_and_slide_sourcelike()->bool:
	var collided := false
	# Reset previously detected floor
	touchingFloor  = false

	#check floor
	var checkMotion := velocity * (1/60.)
	checkMotion.y  -= gravAmount * (1/360.)
		
	var testcol := move_and_collide(checkMotion, true)

	if testcol:
		var testNormal = testcol.get_normal()
		if testNormal.angle_to(up_direction) < deg_to_rad(45) :
			touchingFloor = true

	# Loop performing the move
	var motion := velocity * get_delta_time()
	
	for step in max_slides:
		var collision := move_and_collide(motion)
		if not collision:
			# No collision, so move has finished
			break

		# Calculate velocity to slide along the surface
		var normal = collision.get_normal()
		motion = collision.get_remainder().slide(normal)
		velocity = velocity.slide(normal)
		# Collision has occurred
		collided = true
	return collided
	
func get_delta_time() -> float:
	if Engine.is_in_physics_frame():
		return get_physics_process_delta_time()
	return get_process_delta_time()
