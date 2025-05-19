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
var playerVelocity: Vector3 = Vector3.ZERO # player's calculated velocity
var playerSpeed = 0 # speed of player to prevent too many playerVelocity.length calls
var onFloor = false
const maxvelocity = 100; #this might not seem insane but keep in mind 20 is walking speed

#crouching/jumping/sprinting (modified movement) variables
var touchingFloor = true
var canjump = true
var jumpheight = 2
var sprinting = false
var crouching = false

var crouchSliding = false
const crouchSlideStart = 17
const crouchSlideEnd = 4
const crouchSlideFric = 0.3


# these are all VERY important variables and as such I'll talk a lot about them
const debugging = false #except this one it just decides debug text
#How long it takes the player to get up to full steam
const sprintMod = 2 #it takes time to get up to a sprint though
const walkMod = 50 # walking players have a lot of control
const crouchMod = 200 # crouching players have a LOT of control

# used to limit speed. Affected by crouch and sprint bonus
var curMax = 12
const walkSpeed = 12 #16
const crouchSpeed = 7
const sprintSpeed = 18

#This is a force applied to the player each time. It is applied AFTER acceleration is calculated
const friction = 2 # 3 
#this is similar to friction. at 50  3 equal to around 4 units of speed loss per tick
const stopspeed = 50 # 50
# used as a constant in  dosourcelikeaccelerate
const accelerate = 5 #7 #WHY WAS THIS A THOUSAND??? HUH??????


#if friction is too high, it SEEMS like it totally zeroes out playerVelocity, but
#somehow speed seems to still be applied after the fact?
# this seems to be the case.
#if so, does this mean that friction was useless outside of stopping?
#that seems like it would make a lot of sense.


@onready var playerCam = $came
@onready var playerShape = $shape
@onready var playerCollider = $playercollide

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		InputMouse(event)
		
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event.is_action_pressed("ui_click"):
		7
		
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#this might seem odd, but without these checks in this way,
	# the player only sprints for 5-6 ticks before stopping.

	if (event.is_action_pressed("ui_sprint")):
		sprinting = true
	if event.is_action_released("ui_sprint"):
		sprinting = false
	
	
	if Input.is_action_pressed("ui_crouch"):
		if(!crouching): #if we weren't already crouching, update camera
			transitionCrouch(true) ## having this here...
			crouching = true
	if Input.is_action_just_released("ui_crouch"):
		if(crouching): #if we're leaving crouching, alsp update camera
			transitionCrouch(false) ##and having this here feels like bad code
			crouching = false
	

		
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
	
	#update the movement bonus based on our current mode
	var bonus = walkMod # 50 - good control
	if(crouching):
		bonus = crouchMod # 150 - EXCELLENT control
	elif(sprinting):
		bonus = sprintMod #1 - poor control
		
	leftright += int(bonus) * (int(Input.get_action_strength("ui_left") )) 
	leftright -= int(bonus) * (int(Input.get_action_strength("ui_right"))) 
	
	forback += int(bonus) * (int(Input.get_action_strength("ui_up") ))
	forback -= int(bonus) * (int(Input.get_action_strength("ui_down")))
	
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
	
# these need to be moved once I fix viewbobbing
var prevBob = 0;
var bobOffset = 0;
func _physics_process(delta: float) -> void:
	
	#Deal with inputs
	getInputs()
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		ViewAngles()
	
	#start our decision tree for movement
	handleMove(delta)
	checkVelocityAndMove() #now that we've calculated, actually apply the move
	
	#CAMERA CODE BELOW
	#CrouchCamera()
	#Adjust FOV. 87 feels the best; 85 too low and 90 too high
	playerCam.fov = clamp(87 + sqrt(playerSpeed), 90, 180) 
	
	#TODO: apply camera tilt by amount of sideways velocity
	
	#create viewbob
	#bob_time += delta * float(is_on_floor())
	#bobOffset = doHeadBob(bob_time, prevBob) # this needs more tweaking but it's fine for now
	#playerCam.transform.origin.y = bobOffset+1.75
	#prevBob = bobOffset

const bobAmplitude = 0.05
const bobFreq = 2
var bob_time = 0

# function that applies a headbob. Temporarily disabled.
func doHeadBob(time, prev)->float:
	
	#var velocityMult = 1
	
	#create a ratio that's dependent on playerspeed. 
	#rougly between 1 and 1.5
	var newRatio =  1 + (playerSpeed / (curMax * 2 ))
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

#Updates the player camera as they enter or leave a crouching state.
func transitionCrouch(entering):
	
	if(playerShape.scale.y > 1 || playerShape.scale.y < 0.2 || playerCollider.scale.y > 1 || playerCollider.scale.y < 0.2 ):
		return
	
	if(entering): #we are entering crouch
		playerShape.scale.y -= 1
		playerCollider.scale.y -= 1

	else: #we are exiting crouch
		#TODO: add a check to see if the player has enough room TO stand
		#return if they don't
		playerShape.scale.y += 1
		playerCollider.scale.y += 1
	
	#in theory this code should never do anything since we have an early return but I've left it JIC
	playerShape.scale.y = clamp(playerShape.scale.y, 0.2, 1)
	playerCollider.scale.y = clamp(playerCollider.scale.y, 0.2, 1)
	
# this is the MAIN function that determines where and how the player will move
func handleMove(delta):
	
	if (is_on_floor()):
		
		if(crouchSliding):
			doCrouchSlide(delta)
		
		else:
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
	
	#this was moved to checkVelocityandmove
	#if playerVelocity.length() > maxvelocity:
		#print("MAX VELOCITY HIT!")
		##playerVelocity = maxvelocity playervelocity is a VECTOR. what???
		##return # this still doesn't reduce the player velocity by a serious amount
		#playerVelocity *= 0.5 #this seems to work!


func handleFloorSourcelike(delta):
		#TODO: ADD A TIMER 
		#what did I mean by add a timer???? huh??
	
	#alter the forward movement by camera's azimuth rotation. shouldnt do anything yet.
	var forwAngle = (Vector3.FORWARD).rotated(Vector3.UP, playerCam.rotation.y).normalized()
	var sideAngle = (Vector3.LEFT).rotated(Vector3.UP, playerCam.rotation.y).normalized()
	# hey wait shouldn't one of these be y and the other be x?
	
	
	
	#calculate a vector based of our inputs and angles
	var desiredVec = (leftright * sideAngle) + (forback * forwAngle)
	
	var desiredDir = desiredVec.normalized()
	var desiredSpeed = desiredVec.length()
	
	#a really funny bug to have happen was zeroing out the desiredvec.y here
	#which meant you could just phase through the floor by trying hard enough. 
	#and also fly.
	
	#Apply conditional modifiers to our max speed
	curMax = walkSpeed;
	var fricMod = 1;
	
	if(crouching): # Enter into a crouchslide!
		curMax = crouchSpeed; #only apply crouch movement bonus
		if(playerSpeed > crouchSlideStart):
			crouchSliding = true
			print("crouchsliding! speed:", playerSpeed)
	elif(sprinting): curMax = sprintSpeed; 
	
	
	
	if desiredSpeed !=0.0 and desiredSpeed>curMax:
		desiredVec *= curMax / desiredSpeed # update our vector to not be too silly
		desiredSpeed = curMax # clamp it
	
	desiredVec.y = 0; #but no y. 
	doSourceAccelerate(desiredDir, desiredSpeed, delta)
	
		#deal with friction
	handleFriction(delta, fricMod)

#crouchsliding is much like walking, except we ignore keyboard inputs and only coast on mouse
func doCrouchSlide(delta):
	
	#Crouchsliding will continue as long as the player is fast enough or still crouching
	if(!(crouching) || (playerSpeed < crouchSlideEnd)):
		print("No longer crouchsliding! speed:", playerSpeed)
		crouchSliding = false #stop crouchsliding
		handleMove(delta) #don't return, but instead break loop and re-evaluate
	
	
	
	#var forwAngle = (Vector3.FORWARD).rotated(Vector3.UP, playerCam.rotation.y).normalized()
	#var sideAngle = (Vector3.LEFT).rotated(Vector3.UP, playerCam.rotation.y).normalized()
	#
	##calculate a vector based of our inputs and angles
	#var desiredVec = (sideAngle + forwAngle) #should we add some constant?
	#
	#var desiredDir = desiredVec.normalized()
	#var desiredSpeed = desiredVec.length()
	#
	##ordinarily, there'd be a speed check here, but we don't have to worry 
	##about players gaining speed while crouchsliding 
	#
	#desiredVec.y = 0; #but no y. 
	#doSourceAccelerate(desiredDir, desiredSpeed, delta)
	
		#deal with friction
	handleFriction(delta, crouchSlideFric)	


func doSourceAccelerate(desiredDir, desiredSpeed, delta):
	
	var currentspeed = playerVelocity.dot(desiredDir) # are we changing direction?
	var addedspeed = desiredSpeed - currentspeed # reduce by amount
	
	if addedspeed <= 0: #no need to do anything
		return
	
	var acelspeed = accelerate * delta * desiredSpeed
	
	playerVelocity.y -= gravAmount * delta
	
	
	for i in range(3): #the comment says adjust velocity but i truly have no idea what this does
		playerVelocity+= acelspeed * desiredDir
	
	playerSpeed = playerVelocity.length() # update playerspeed
	

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
	playerSpeed = playerVelocity.length() #update playerSpeed

#the air movement function
# this differs from sourcelike floor in a few ways:
# 1: no multipliers on crouching/spring
# 2: a LOT less control

func handleSourcelikeAir(delta):
	 
	var forward = Vector3.FORWARD
	var side = Vector3.LEFT
	
	forward = forward.rotated(Vector3.UP, playerCam.rotation.y).normalized()
	side = side.rotated(Vector3.UP, playerCam.rotation.y).normalized()
	
	playerVelocity.y -= gravAmount * delta
	playerSpeed = playerVelocity.length() #update speed
	
	var fmove = forback * 0.1
	var smove = leftright * 0.1
	
	var wishvel = (side * smove + forward * fmove) * 0.1 # players should NOT have a lot of air control
	
	# Zero out y value
	wishvel.y = 0
	
	var wishdir = wishvel.normalized()
	# VectorNormalize in the original source code doesn't actually return the length of the normalized vector
	# It returns the length of the vector before it was normalized
	var wishspeed = wishvel.length()
	
	# TODO: UPDATE THIS
	# clamp to game defined max speed # but what if we didn't? :)
	if wishspeed != 0.0 and wishspeed > curMax:
		wishvel *= curMax / wishspeed
		wishspeed = curMax
	
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
	playerSpeed = playerVelocity.length()

################################ GENERALIZED MOVEMENT

#this is the function that ACTUALLY causes the player to move
func checkVelocityAndMove():
	if playerSpeed > maxvelocity:
		if(debugging): print("MAX VELOCITY HIT!")
		#playerVelocity = maxvelocity playervelocity is a VECTOR. what???
		#return # this still doesn't reduce the player velocity by a serious amount
		playerVelocity *= 0.5 #this seems to work!
		playerSpeed = playerVelocity.length()
	
	if(debugging):
		if(playerSpeed > 0):
			print("Velocity:", playerSpeed)
		
	velocity = playerVelocity
	move_and_slide()
	playerVelocity = velocity
	playerSpeed = playerVelocity.length()

#updates the playerVelocity variable based on friction variables
func handleFriction(delta, fricMod):
	if playerSpeed <= 0:
		return
	
	#godot didn't like this code so I've commented it out 
	#var control = stopspeed if speed < stopspeed else speed
	var control = playerSpeed
	if (playerSpeed < stopspeed) :
		control = stopspeed * fricMod #fricmod lets us dynamically alter applied friction
	
	# Add the amount to the drop amount.
	var drop = control * friction * delta * fricMod

	# scale the velocity
	var newspeed = playerSpeed - drop
	if newspeed < 0:
		newspeed = 0
	
	
	
	if newspeed != playerSpeed:
		# Determine proportion of old speed we are using.
		newspeed /= playerSpeed
		# Adjust velocity according to proportion.
		
		#var speedcheck = playerVelocity.length()
		playerVelocity *= newspeed
		playerSpeed = playerVelocity.length()
	
		#if(debugging):
			
		#	print("Old/hampered velocity:", speedcheck, " : ", playerVelocity.length())


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
	
	
