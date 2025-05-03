#extends  "res://playershared.gd"
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const sourcelike = true
const gravAmount = 60

#player camera variables
var ylook : float
var xlook : float
# even more but constants
var mousesensitivity = 0.3
var ply_maxlookangle_down = -90
var ply_maxlookangle_up = 90
var ply_ylookspeed = 0.3
var ply_xlookspeed = 0.3

#player input/movement variables
const walkspeed = 20 #basic multiplier to walking
const maxIn = 4096 #boundaries for the most "walking" we want to be doing
const minIn = -4096
var leftright : float #variables for how "walking" we are in either cardinal direction
var forback : float
var playerVelocity: Vector3 = Vector3.ZERO
var onFloor = false

#crouching/jumping variables
var touchingFloor = true
var justjumped = false
var crouching = false
var canjump = true
var jumpheight = 4

const maxspeed = 32 # used in player velocity calculations as a clamp - handlefloorsourcelike
const accelerateby = 7 # used in dosourcelikeaccelerate #WHY WAS THIS A THOUSAND??? HUH??????
const gravityAmount = 140


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
	var bonus = 50
	
	#TODO: add sprinting code that doubles bonus.
	
	leftright += int(walkspeed) * (int(Input.get_action_strength("ui_left") * bonus)) # why are there constants here?
	leftright -= int(walkspeed) * (int(Input.get_action_strength("ui_right") * bonus)) #like, why not just do 20*50
	
	forback += int(walkspeed) * (int(Input.get_action_strength("ui_up") * bonus))
	forback -= int(walkspeed) * (int(Input.get_action_strength("ui_down") * bonus))
	
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
		


func _physics_process(delta: float) -> void:
	if sourcelike:
		getInputs()
		#playerCam.fov = clamp(70+sqrt(playerVelocity*7),90, 180) #formerly playerVelocity.length()*7
		
	
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			ViewAngles()
		
		
		handleMove(delta, Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down"))
	else:
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		handleMove(delta, input_dir) 
	
func handleMove(delta, inputs):
	if (is_on_floor()): #air movement is the same
	#	handleair(delta)
		
		handleFloorSourcelike(delta)
		
	else: 
		#if sourcelike:
		handleSourcelikeAir(delta)
		justjumped = false
		#else:
		#	handlefloorTemplate(delta, inputs)
	
	if Input.is_action_pressed("ui_jump") && canjump:
		if not crouching:
			touchingFloor = false
			justjumped  = true
			doJump()
			#
			#state_machine.transition_to("Air", {do_jump = true})
		

func handleFloorSourcelike(delta):
	#alter the forward movement by camera's azimuth rotation. shouldnt do anything yet.
	var forwAngle = (Vector3.FORWARD).rotated(Vector3.UP, playerCam.rotation.y).normalized()
	var sideAngle = (Vector3.LEFT).rotated(Vector3.UP, playerCam.rotation.y).normalized()
	
	#calculate a vector based of our inputs and angles
	var desiredVec = (leftright * sideAngle) + (forback * forwAngle)
	
	#deal with friction
	handleFriction(delta)
	
	
	var desiredDir = desiredVec.normalized()
	var desiredSpeed = desiredVec.length()
	
	#a really funny bug to have happen is zeroing out the desiredvec.y
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
	
	print("accelerating")
	var acelspeed = accelerateby * delta * desiredSpeed
	
	#playerVelocity -= gravAmount * delta
	acelspeed = min(acelspeed, addedspeed) #cap by addspeed
	
	for i in range(3): #the comment says adjust velocity but i truly have no idea what this does
		playerVelocity+= acelspeed * desiredDir
	
	#now that we've updated velocity, the godot function will take it from here
	checkVelocityAndMove()
	
# given inputs and our delta, figures out
func handlefloorTemplate(delta, inputs):
	var direction := (transform.basis * Vector3(inputs.x, 0, inputs.y)).normalized()
	if direction:
		playerVelocity.x = direction.x * SPEED
		playerVelocity.z = direction.z * SPEED
	else:
		playerVelocity.x = move_toward(playerVelocity.x, 0, SPEED)
		playerVelocity.z = move_toward(playerVelocity.z, 0, SPEED)
	checkVelocityAndMove()

##################################AIR MOVEMENT
func doJump():
	#stats.snap = Vector3.ZERO

	if not (canjump) ||  velocity.y>15:
			return
		
	var flGroundFactor = 1.0
	var flMul : float
	
	if crouching: #trying to emulate that crouch jumping is slightly higher than jump crouching but not completely accurate. Reasion why you jump higher mid crouch is because the game forgets to apply gravity for the first frame. This attempts to recreate it by removing one frame of gravity to make up for it
		flMul = sqrt(2 * gravAmount * jumpheight) + ((1./60.) * gravAmount)
		
	else:
		move_and_collide(Vector3(0, 2-playerShape.scale.y, 0))		
		flMul = sqrt(2 * gravAmount * jumpheight)
	var jumpvel =  flGroundFactor * flMul  + max(0, playerVelocity.y)
	playerVelocity.y = max(jumpvel, jumpvel + playerVelocity.y)
	#print("nomral jump: ",playerVelocity.y)


func handleair(delta):
	velocity += get_gravity() * delta
	checkVelocityAndMove()

func handleSourcelikeAir(delta):
	print("in air!")
	var forward = Vector3.FORWARD
	var side = Vector3.LEFT
	
	forward = forward.rotated(Vector3.UP, playerCam.rotation.y)
	side = side.rotated(Vector3.UP, playerCam.rotation.y)
	
	forward = forward.normalized()
	side = side.normalized()
	
	#var forwAngle = (Vector3.FORWARD).rotated(Vector3.UP, playerCam.rotation.y).normalized()
	#var sideAngle = (Vector3.LEFT).rotated(Vector3.UP, playerCam.rotation.y).normalized()
	
	var fmove = forback
	var smove = leftright
	
	#snap = Vector3.ZERO
	playerVelocity.y -= gravityAmount * delta
	
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
	checkVelocityAndMove() #and move afterwards
	
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
	var maxvelocity = 35000; #why isn't this a constant declared higher? because you cant assign vectors to ints
	
	if playerVelocity.length() > maxvelocity: #how does declaring it down here do anything? genuinely couldnt tell you
		playerVelocity = maxvelocity
	
	velocity = playerVelocity
	move_and_slide()
	playerVelocity = velocity

func handleFriction(delta):
	var speed = playerVelocity.length()
	var friction = 4 # I know this should be a constant but I'm just trying to get things working at this point
	var stopspeed = 100
	var control = stopspeed if speed < stopspeed else speed
	var drop = 0 + (control * friction * delta)
	var newspeed = speed - drop
	if newspeed < 0:
		newspeed = 0
	if newspeed != speed:
		# Determine proportion of old speed we are using.
		newspeed /= speed
		# Adjust velocity according to proportion.
		playerVelocity *= newspeed
		
func move_and_slide_sourcelike()->bool:
	var collided := false
	# Reset previously detected floor
	touchingFloor  = false

	#check floor
	var checkMotion := velocity * (1/60.)
	#checkMotion.y  -= stats.ply_gravity * (1/360.)
		
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
