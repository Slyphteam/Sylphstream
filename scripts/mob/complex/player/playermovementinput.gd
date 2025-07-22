#this script is the PRIMARY driver for kinematic player behavior and input/output.
#This script also communicates with the invenManager script for reloading, shooting,
#and general interactions with the held object

extends CharacterBody3D

#deprecated variable from back when i used template movement, keeping for sentimental purposes
#const sourcelike = true 
const gravAmount = 60

@export var quakelike: bool = false ##Whether or not we use the (nearly identical) quakelike function

#player camera variables
var ylook : float = 0
var xlook : float = 0
var mousesensitivity = 0.25

#player input/movement variables
var leftright : float ##variables for how "walking" we are in either cardinal direction
var forback : float
var playerVelocity: Vector3 = Vector3.ZERO # player's calculated velocity
var playerSpeed = 0 ## speed of player to prevent too many playerVelocity.length calls
const maxvelocity = 100; ##this might not seem insane but keep in mind 20 is walking speed

#crouching/jumping/sprinting (modified movement) variables
var canjump = true
var jumpheight = 2
var sprinting = false
var crouching = false
var aiming = false

var crouchSliding = false
const crouchSlideStart = 17 ##start speed
const crouchSlideEnd = 4 ##end speed
const crouchSlideFric = 0.15 ##reductive multiplier on friction

#How long it takes the player to get up to full steam, based on speed bonuses
const sprintMod = 3 ##it takes time to get up to a sprint though
const walkMod = 3 ## walking players have a lot of control
const crouchMod = 5 ## crouching players have a LOT of control


var curMax = 13 ## used to limit speed. Affected by crouch and sprint bonus
const walkSpeed = 13 
const crouchSpeed = -5.5 ## negative "bonus" of 6 to player speed
const sprintSpeed = 5 ## positive bonus of 5
const aimSpeed = -4 ##mouse sensitivity is handled in toggle_ADS_Stats


const friction = 100 ##This is a force applied to the player each time. It is applied AFTER acceleration is calculated
# used as a constant in dosourcelikeaccelerate
const accelerate = 5 #WHY WAS THIS A THOUSAND??? HUH?????? WHAT???

@onready var camCage = $camCage
@onready var playerCam = $camCage/came
@onready var playerShape = $playermodel
@onready var playerCollider = $playercollidercapsule
@onready var invenManager: PLAYERINVENMANAGER = $camCage/came/weapon_rig
@onready var uiInfo = $"Player UI"

func _ready():
	Globalscript.thePlayer = self


##Handles player input. You may notice that there are checks on both Input and event.
##event will only apply the first frame, but event will happen for every frame the key is held.
func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		input_Mouse(event)
	
	#TODO: update this to the sprinting paradigm because you now know a better way
	
	if Input.is_action_pressed("ui_click"):
		# are we in mouse mode?
		if (Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED && Globalscript.isPlaying):
			invenManager.doShoot() #if so, shoot our current weapon
		
		#if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if Input.is_action_just_released("ui_click", false):
		#though strange, this code is necessary as the player can be holding mouse and no other inputs
		#which
		invenManager.unShoot() 
	
	if Input.is_action_pressed("ui_sprint"):
		sprinting = true
	else:
		sprinting = false
	
	if Input.is_action_pressed("ui_crouch"):
		if(!crouching): #if we weren't already crouching, update camera
			transition_Crouch(true) # having this here...
			crouching = true
	if Input.is_action_just_released("ui_crouch"):
		if(crouching): #if we're leaving crouching, alsp update camera
			transition_Crouch(false) #and having this here feels like bad code
			crouching = false
	
	if event.is_action_pressed("ui_reload"):
		invenManager.startReload()
		
	if event.is_action_pressed("ui_ads"):
		invenManager.toggleSights()
		toggle_ADS_Stats()
	
	if (event.is_action_pressed("ui_interact") && !event.is_echo()):
		do_Interact_Raycast()
	
	#Presumably, there's a better way to do this. Presumably...
	if event.is_action_pressed("ui_num1"):
		invenManager.change_To_Slot(1)
		
	if event.is_action_pressed("ui_num2"):
		invenManager.change_To_Slot(2)
	if event.is_action_pressed("ui_num3"):
		invenManager.change_To_Slot(3)
	if event.is_action_pressed("ui_num4"):
		invenManager.change_To_Slot(4)
	#if event.is_action_pressed("ui_num5"):
		#invenManager.change_To_Slot(5)

##Cleanliness function that just makes a short-ranged raycast
func do_Interact_Raycast():
	
	var space = invenManager.get_space_state()
	var orig:Vector3 = playerCam.project_ray_origin(get_viewport().size / 2)
	var end:Vector3 = orig + playerCam.project_ray_normal(get_viewport().size / 2) * 100
		
	var raycheck = PhysicsRayQueryParameters3D.create(orig, end, 4) #3 is 0xb 0010etc, or the player interaction layer
	raycheck.collide_with_bodies = true
	var castResult = space.intersect_ray(raycheck)
		
	if(castResult):
		#print(castResult)
		var hitObject = castResult.get("collider")
		if(hitObject.is_in_group("player_interactible")): #check if we even CAN interact before anything else
			var castLocation = castResult.get("position")
			var dist = (orig - castLocation).length()
			if(dist <= 2.5):
				var interactResult = hitObject.interact_By_Player(self)
				if(interactResult):
					print("K-chk!")

func input_Mouse(event):
	xlook += -event.relative.y * mousesensitivity
	ylook += -event.relative.x * mousesensitivity
	xlook = clamp(xlook, -90, 90)

##Apply camera and body rotation based on xlook and ylook variables
func update_Viewangles():
	camCage.rotation_degrees.x = xlook #move the camcage up/down
	rotation_degrees.y = ylook #move our whole self left/right

##Handles proprietary input logic for specifically WASD movement
func check_Directional_Movement():
	#update the movement bonus based on our current mode
	var bonus = walkMod 
	var limit = walkSpeed
	if(crouching):
		limit += crouchSpeed 
		bonus = crouchMod 
	elif(sprinting):
		limit += sprintSpeed
		bonus = sprintMod 
		
	leftright += int(bonus) * (int(Input.get_action_strength("ui_left") )) 
	leftright -= int(bonus) * (int(Input.get_action_strength("ui_right"))) 
	
	forback += int(bonus) * (int(Input.get_action_strength("ui_up") ))
	forback -= int(bonus) * (int(Input.get_action_strength("ui_down")))
	
	# clamp left/right movement
	if Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		leftright = 0
	else:
		leftright = clamp(leftright, (0-limit), limit) 
	#clamp forwards/backwards input
	if Input.is_action_just_released("ui_up") or Input.is_action_just_released("ui_down"):
		forback = 0
	else:
		forback = clamp(forback, (0-limit), limit)


func _physics_process(delta: float) -> void:
	
	#Deal with WASD movements the proprietary way
	check_Directional_Movement()
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		update_Viewangles()
	
	#start our decision tree for movement
	handle_Move(delta)
	checkVelocityAndMove() #now that we've calculated, actually apply the move
	
	#viewtilt and headbob are in the camera script 
	#playerCam.fov = clamp(87 + sqrt(playerSpeed), 90, 180) #caused jitteriness with weapons to be visible.


##Updates the player camera as they enter or leave a crouching state.
func transition_Crouch(entering):
	if(entering): #we are entering crouch
	#	playerShape.scale.y -= 0.8 #it's jank so we are no longer changing the playermodel's size
		playerCollider.scale.y -= 0.8

	else: #we are exiting crouch
		#TODO: add a check to see if the player has enough room TO stand
		playerCollider.scale.y += 0.8

##Function that toggles mouse sensitivity. Speed is handled per-frame. Maybe make dependent on weapons stat????
func toggle_ADS_Stats():
	if(aiming): # we want to un-aim
		mousesensitivity = 0.25
		aiming = false
	else:
		mousesensitivity = 0.15
		aiming = true
		
##This is the MAIN function that determines where and how the player will move
func handle_Move(delta):
	
	#i should really really REALLY REALLY R E A L L Y refactor this section
	if (is_on_floor()):
		if(crouchSliding): #Crouchsliding doesn't factor in WASD keypresses. 
			#(does that mean you can "build" keypress speed when sliding and then immediately gain from it when you exit?)
			do_Crouch_Slide(delta)
		
		else:
			#Does a fairly good job emulating source jumping allowance logic
			#can be modified for auto-bunnyhopping but that's super busted
			if (not canjump):
				if(not Input.is_action_pressed("ui_jump") ): 
					canjump = true
			
			handle_Floor_Sourcelike(delta)	
	else: 
		handle_Sourcelike_Air(delta)
	
	if Input.is_action_pressed("ui_jump") && canjump:
		if not crouching:
			canjump = false
			do_Jump()
	

##this is the PRIMARY function that handles floor logic.
func handle_Floor_Sourcelike(delta):
	
	# split our horizontal rotation into x and y compontents (technically x and z but i digress)
	var forwAngle = (Vector3.FORWARD).rotated(Vector3.UP, playerCam.global_rotation.y).normalized()
	var sideAngle = (Vector3.LEFT).rotated(Vector3.UP, playerCam.global_rotation.y).normalized()
	
	#calculate a vector based of our inputs and angles
	var desiredVec = (leftright * sideAngle) + (forback * forwAngle)
	
	var desiredDir: Vector3 = desiredVec.normalized()
	var desiredSpeed = desiredVec.length()
	
	#a really funny bug to have happen was zeroing out the desiredvec.y here instead of lower
	#which meant you could just phase through the floor by trying hard enough. and also fly.
	
	
	curMax = walkSpeed;
	
	#Apply conditional modifiers to our max speed
	if(aiming):
		if(crouching): #aiming and crouching gets ridiculously slow if we apply crouchSpeed penalty also
			curMax -=1 
		else:
			curMax += aimSpeed 
			

	if(crouching): 
		curMax += crouchSpeed; #only apply crouch movement bonus
		if(playerSpeed > crouchSlideStart): 
			crouchSliding = true # Enter into a crouchslide! (will only apply effects next frame)
			#print("crouchsliding! speed:", playerSpeed)
	elif(sprinting): curMax += sprintSpeed; 
	
	#player is not moving if speed is less than 3.5, huh?
	if desiredSpeed !=0.0 and desiredSpeed > curMax:
		
		desiredVec *= curMax / desiredSpeed # update our vector to not be too silly
		desiredSpeed = curMax # clamp it
		#print("limited speed: ", desiredSpeed)
	
	desiredVec.y = 0; #zero out the y
	
	do_Source_Accelerate(desiredDir, desiredSpeed, delta)

	#deal with friction
	handle_Friction(delta, 1)

##Supercedes normal floor movement. Ignore keyboard/mouse directional inputs and just coast.
func do_Crouch_Slide(delta):
	#Crouchsliding will continue as long as the player is fast enough or still crouching
	if(!(crouching) || (playerSpeed < crouchSlideEnd)):
		print("No longer crouchsliding! speed:", playerSpeed)
		crouchSliding = false #stop crouchsliding
		handle_Move(delta) #don't return, but instead break loop and re-evaluate
	
	handle_Friction(delta, crouchSlideFric) #crouchslidefric is a static variable = 0.15

##Function that calculates and updates player's velocity
func do_Source_Accelerate(desiredDir: Vector3, desiredSpeed, delta):
	
	var currentspeed = playerVelocity.dot(desiredDir) # are we changing direction?
	var addedspeed = desiredSpeed - currentspeed # reduce by amount
	
	if addedspeed <= 0: #no need to do anything
		return
	
	var acelspeed = accelerate * delta * desiredSpeed
	
	playerVelocity.y -= gravAmount * delta
	
	#var newPlayerVel = Vector3(playerVelocity.x + (desiredDir.x * acelspeed), 
							   #playerVelocity.y + (desiredDir.y * acelspeed), 
							   #playerVelocity.z + (desiredDir.z * acelspeed))
	#playerVelocity = newPlayerVel
	
	#There's some weird syntax going on here that I can't get to work any other way.
	#which really annoys me. I've done debugging. I just can't recreate the logic, for SOME reason
	for i in range(3): 
		playerVelocity+= acelspeed * desiredDir
		
	playerSpeed = playerVelocity.length() # update playerspeed

##################################AIR MOVEMENT

func do_Jump():
	
	var flGroundFactor = 1.0
	var flMul : float
	
	#trying to emulate that crouch jumping is slightly higher than jump crouching but not completely 
	#accurate. Reasion why you jump higher mid crouch is because the game forgets to apply gravity for 
	#the first frame. This attempts to recreate it by removing one frame of gravity to make up for it
	
	if crouching: 
		flMul = sqrt(2 * gravAmount * jumpheight) + ((1./60.) * gravAmount)
		
	else:
		move_and_collide(Vector3(0, 2-playerShape.scale.y, 0)) #TODO: make sure playershape here doesnt cause issues
		flMul = sqrt(2 * gravAmount * jumpheight)
	var jumpvel =  flGroundFactor * flMul  + max(0, playerVelocity.y)
	playerVelocity.y = max(jumpvel, jumpvel + playerVelocity.y)
	playerSpeed = playerVelocity.length() #update playerSpeed

#the air movement function
# this differs from sourcelike floor in a few ways:
# 1: no multipliers on crouching/spring
# 2: a LOT less control
##Very similar to floor movement, but no multipliers on crouch/sprinting and less control
func handle_Sourcelike_Air(delta):
	 
	#again, split horizontal direction into x and y compontents 
	var forward =  Vector3.FORWARD.rotated(Vector3.UP, playerCam.global_rotation.y).normalized()
	var side = Vector3.LEFT.rotated(Vector3.UP, playerCam.global_rotation.y).normalized()
	
	playerVelocity.y -= gravAmount * delta
	playerSpeed = playerVelocity.length() #update speed
	
	var fmove = forback * 0.1
	var smove = leftright * 0.1
	
	var wishvel = (side * smove + forward * fmove) * 0.1 # players should NOT have a lot of air control
	
	# Zero out y value
	wishvel.y = 0
	
	if(quakelike):
		do_Qke_AirAccelerate(wishvel, delta) #let the airaccelerate function do its work
		return
	
	var wishdir = wishvel.normalized()
	var wishspeed = wishvel.length()
	
	# TODO: UPDATE THIS
	# clamp to game defined max speed # but what if we didn't? :)
	if wishspeed != 0.0 and wishspeed > curMax:
		wishvel *= curMax / wishspeed
		wishspeed = curMax
	
	do_Source_AirAccelerate(wishdir, wishspeed, delta) #let the airaccelerate function do its work

##Functionally, almost identical to do_source_airaccelerate, I just made this for 2 reasons
#1) to get a better understanding of the physics
#2) To see whats up with bunnyhopping
#I currently have friction tuned too high for airstrafing to work, though.
#also, the checkspeed should NOT be thirty. it should be 1/10th of our speed max.
func do_Qke_AirAccelerate(desiredVel, delta):
	
	#quakelike movement
	
	#originally i was just going to rewrite do_Source_AirAccelerate
	#which is why all these variable names are weird and short
	#but then i realized that was stupid so now they just have odd names in their own function
	var wspd = desiredVel.length()
	var vvel = desiredVel.normalized()
	
	if(wspd > 30): #30 units is in QUAKE units, convert this >:(
		wspd = 30
	
	var qkecurspd = playerVelocity.dot(vvel)
	
	
	var qkespd = wspd - playerSpeed #aka add_speed
	if(qkespd <=0):
		return
	
	var qkespdlmt = desiredVel.length() * accelerate * delta #aka accel_speed
	if(qkespdlmt > qkespd):
		qkespdlmt = qkespd
	
	for i in range(3):
		playerVelocity += qkespdlmt * desiredVel
	
	#here I am. trying to avoid the for loop again.
	#playerVelocity.x += qkespdlmt * desiredDir.x
	#playerVelocity.y += qkespdlmt * desiredDir.y
	#playerVelocity.z += qkespdlmt * desiredDir.z
	
	playerSpeed = playerVelocity.length()
	

func do_Source_AirAccelerate(desiredDir, desiredSpeed, delta):
	
	var accel = 20 #global airaccelerate 
	desiredSpeed = min(desiredSpeed, 15) # global airspeed cap 
	# See if we are changing direction a bit
	var currentspeed = playerVelocity.dot(desiredDir)
	# Reduce wishspeed by the amount of veer.
	var addspeed = desiredSpeed - currentspeed
	
	if addspeed <= 0: # early return
		return
#
	# Determine amount of accleration.
	var accelspeed = accel * desiredSpeed * delta 
	# Cap at addspeed
	accelspeed = min(accelspeed, addspeed)
	#
	for i in range(3):
		# Adjust velocity.
		playerVelocity += accelspeed * desiredDir
	playerSpeed = playerVelocity.length()

################################ GENERALIZED MOVEMENT

##this is the function that ACTUALLY causes the player to move
func checkVelocityAndMove():
	if playerSpeed > maxvelocity:
		print("MAX VELOCITY HIT!")
		playerVelocity *= 0.5 #
		playerSpeed = playerVelocity.length()
	
		
	velocity = playerVelocity
	move_and_slide()
	playerVelocity = velocity
	playerSpeed = playerVelocity.length()
	justSnapped = do_Floorsnap_Check()
	
	onfloorPrev = is_on_floor()

var onfloorPrev ##Were we just on the floor last frame?
var justSnapped
##Does a test to see if the player has a "ground" beneath them they can snap to.
func do_Floorsnap_Check():
	if(! is_on_floor() && playerVelocity.y == 0 && (onfloorPrev || justSnapped)): #TODO: use demorgans and have this return if we dont wanna do things
		var moveCheckRes = PhysicsTestMotionResult3D.new()
		var checkParameters = PhysicsTestMotionParameters3D.new()
		checkParameters.from = global_transform #Our worldspace
		checkParameters.motion = Vector3(0, -0.26, 0) #down -0.26
		
		if(PhysicsServer3D.body_test_motion(self.get_rid(), checkParameters, moveCheckRes)):
			var neededMove = moveCheckRes.get_travel().y ##How far we need to go to be about to collide
			position.y += neededMove #wow. this should be better code.
			apply_floor_snap() #supposedly prevents bouncing. IDRC enough to test it, tbh
			return true
			
	return false

##updates the playerVelocity variable based on friction variables
func handle_Friction(delta, fricMod):
	if playerSpeed <= 0:
		return
	
	# Add the amount to the drop amount.
	var drop = friction * delta * fricMod

	# scale the velocity
	var newspeed = playerSpeed - drop
	if newspeed < 0:
		newspeed = 0
	
	if newspeed != playerSpeed:
		# Determine proportion of old speed we are using.
		newspeed /= playerSpeed
		# Adjust velocity according to proportion.
		
		playerVelocity *= newspeed
		playerSpeed = playerVelocity.length()
	
##Unused. Presumably went in place of move_and_slide in checkVelocityAndMove
func move_and_slide_sourcelike()->bool: 
	var collided := false

	#check floor
	var checkMotion := velocity * (1/60.)
	checkMotion.y  -= gravAmount * (1/360.)
		
	var testcol := move_and_collide(checkMotion, true) #Test physics collision for going down

	#if testcol: #Do some testing with this in the future. for now, disabled.
		#var testNormal = testcol.get_normal()
		#if testNormal.angle_to(up_direction) < deg_to_rad(45) :
			#touchingFloor = true #I got rid of touchingfloor as it's just a worse version of is_on_floor() and unchecked

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

##Jolt camera, by degrees x and y. Must be manually fixed by user
func apply_Viewpunch(azimuth: float, zenith: float):
	
	ylook += azimuth
	xlook += zenith

#func apply_Autorecover_Viewpunch() #implement this when you finish the camcage modularity pass
