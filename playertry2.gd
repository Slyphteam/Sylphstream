#extends  "res://playershared.gd"
extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const sourcelike = false

#player input/movement variables
const walkspeed = 20 #basic multiplier to walking
const maxIn = 4096 #boundaries for the most "walking" we want to be doing
const minIn = -4096
var leftright : float #variables for how "walking" we are in either cardinal direction
var forback : float

const maxspeed = 32 # used in player velocity calculations as a clamp - handlefloorsourcelike
const maxacceleration = 1000 # used in dosourcelikeaccelerate


@onready var playerCam = $came
@onready var colliderbottom = $bottom

# handle wasd inputs
# will listen to keypresses and update the movement variables above
func getInputs():
	
	leftright += int(walkspeed) * (int(Input.get_action_strength("ui_left") * 50)) # why are there constants here?
	leftright -= int(walkspeed) * (int(Input.get_action_strength("ui_right") * 50)) #like, why not just do 20*50
	
	forback += int(walkspeed) * (int(Input.get_action_strength("ui_up") * 50))
	forback -= int(walkspeed) * (int(Input.get_action_strength("ui_down") * 50))
	
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
	else:
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		handleMove(delta, input_dir) 
	
func handleMove(delta, inputs):
	if not is_on_floor(): #air movement is the same
		handleair(delta)
	else: 
		if sourcelike:
			handleFloorSourcelike(delta)
		else:
			handlefloorTemplate(delta, inputs)


func handleFloorSourcelike(delta):
	#alter the forward movement by camera's azimuth rotation. shouldnt do anything yet.
	var forwAngle = (Vector3.FORWARD).rotated(Vector3.UP, playerCam.rotation.y).normalized()
	var sideAngle = (Vector3.LEFT).rotated(Vector3.UP, rotation.y).normalized()
	
	#calculate a vector based of our inputs and angles
	var desiredVec = (leftright * sideAngle) + (forback * forwAngle)
	desiredVec.y = 0; #but no y.
	
		#haven't opened this can of worms yet
	#friction(delta)
	
	
	var desiredDir = desiredVec.normalized()
	var desiredSpeed = desiredVec.length()
	
	if desiredSpeed !=0.0 and desiredSpeed>maxspeed:
		desiredVec *= maxspeed / desiredSpeed # update our vector to not be too silly
		desiredSpeed = maxspeed # clamp it
	
	
	#Accelerate(wishdir, wishspeed, ply_accelerate, delta)
	
func doSourceAccelerate(desiredVector, desiredSpeed, delta):
	
	
	#now that we've updated velocity, the godot function will take it from here
	checkVelocityAndMove()

# given inputs and our delta, figures out
func handlefloorTemplate(delta, inputs):
	var direction := (transform.basis * Vector3(inputs.x, 0, inputs.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	checkVelocityAndMove()

func handleair(delta):
	velocity += get_gravity() * delta
	checkVelocityAndMove()
	
func checkVelocityAndMove():
	var maxvelocity = 35000; #why isn't this a constant declared higher? because you cant assign vectors to ints
	if velocity.length() > maxvelocity: #how does declaring it down here do anything? genuinely couldnt tell you
		velocity = maxvelocity
	move_and_slide()


	
