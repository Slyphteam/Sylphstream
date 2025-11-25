extends CharacterBody3D
##Controller code for the Sylph. Relies on sylph_mind for inputs.
@onready var sylphHead = $"sylph head v2"
@onready var collider = $sylphcollider
@onready var sylphModel = $sylphmodel
@onready var mind = $"sylph mind"
@onready var ourHealth = $COMPLEXHEALTHHOLDER
@onready var manager : INVENMANAGER = $"sylph head v2/sylphinventory"
@export var ourTar: Node3D
@export var moveEnabled:bool = false

var shoot = false
func hit_By_Bullet(dam, _damtype, _dir, originator):
	if(originator):
		if(originator == Globalscript.thePlayer):
			print("Ow! You shot me for ", dam, " damage!")
	
	var newHP = ourHealth.take_Dam(dam)
	
	if(newHP <= 0):
		print("OWWW! I just died!")
		
		#will need more work on this in the future
		rotation_degrees.x = 90
	
	
var addedTraining: bool = false 
func interact_By_Player(_playerRef):
	
	
	#mind.do_Debug_Action()
	
	if(!addedTraining):
		print("Adding myself to training pool!")
		Globalscript.enroll_Sylph(mind)
		return
	print("Hi! My current HP is ", ourHealth.health, " with ", ourHealth.aura, " aura")
	
	#mind.do_Single_Thought(1/60)
	#mind.begin_Test()
	#mind.do_Vision()
	



##Moves the Sylph's head with a vector containing the degrees of rotation in vertical, horizontal
func move_Head_Exact(desired: Vector2):
	sylphHead.rotation_degrees.x -= desired.y #up/down. yeah it's subtractive. welcome to godot.
	sylphHead.rotation_degrees.y += desired.x #side/side
	
	#to past self: you have to use the return value for clamp to work, dummy
	sylphHead.rotation_degrees.x = clampf(sylphHead.rotation_degrees.x, -90, 90) 
	
	
	#This code would update the body's rotation, which looked cool, but isn't something I want to deal with yet
	#var newangle = sylphHead.rotation_degrees.y
	#
	#var diff = newangle - collider.rotation_degrees.y
	#if(abs(diff) > 40):
		#collider.rotation_degrees.y = (newangle + collider.rotation_degrees.y) / 2
	
	#super awesome new epic idea: just rotate the 3d model, dummy
	sylphModel.rotation_degrees.y = sylphHead.rotation_degrees.y
	
func get_invenm():
	return manager


#########KINEMATIC CODE BELOW

var goFor:bool = false
var goLef:bool = false
var goRit:bool = false
var goBak:bool = false

func _process(delta):
	if(moveEnabled):
		calcKinemInput()
		doMove(delta)

var walkSpeed = 13
var leftright:float
var forback:float
var sylphVel: Vector3 = Vector3.ZERO
var sylphSpeed = 0

func calcKinemInput():
	
	var bonus = 3
	var limit = walkSpeed * 10 #player walkspeed is 13
	
	#sprint/crouch/whatnot logic would go here
	#this might seem cargo cult-y to the player's kinematic controller
	#but truth be told I have no idea how much or how little I want sylphs to be able to do
	#so I'm keeping the patterns the exact same
	
	if(sylphSpeed == 0 && leftright == 0 && forback == 0): 
		bonus = 90
	
	leftright += int(bonus) * (int(goLef )) * Globalscript.deltaButNotStinky
	leftright -= int(bonus) * (int(goRit )) * Globalscript.deltaButNotStinky
	
	forback -= int(bonus) * (int(goFor)) * Globalscript.deltaButNotStinky
	forback += int(bonus) * (int(goBak )) * Globalscript.deltaButNotStinky
	
	#clamp movement, should be the same as how the player does it
	if(!goLef && !goRit):
		if(leftright > 2): #in the player script this set the input to be 0 straight but im predicting sylphs
							# will be a lot less consistent with their movement; so will need soft stops
			leftright /=2
		else:
			leftright = 0
	else:
		leftright = clamp(leftright, (0-limit), limit)
		
	if(!goFor && !goBak):
		if(forback > 2): 
			forback /=2
		else:
			forback = 0
	else:
		forback = clamp(forback, (0-limit), limit)
	
	#reset all of our inputs for next frame
	if(goFor):
		goFor = false
	if(goLef):
		goLef = false
	if(goRit):
		goRit = false
	if(goBak):
		goBak = false

func doMove(delta):
	#might seem silly to have a function that does nothing but call another function
	#but as mentioned earlier, if I go all out, there'd be stuff like air/crouchslide
	#code between domove and dofloormove
	doFloorMove(delta)
	
	velocity = sylphVel
	move_and_slide()
	sylphVel = velocity
	sylphSpeed = sylphVel.length()

func doFloorMove(delta):
	var forwAngle = (Vector3.FORWARD).rotated(Vector3.UP, sylphHead.global_rotation.y).normalized()
	var sideAngle = (Vector3.LEFT).rotated(Vector3.UP, sylphHead.global_rotation.y).normalized()
	
	#since I changed the "unit" value of forback and leftright, we need to calibrate them
	var paralelImpulse = forback / 10
	var perpImpulse = leftright / 10
	
	#calculate a vector based off our inputs and angles
	var desiredVec = (perpImpulse * sideAngle) + (paralelImpulse * forwAngle)
	var desiredDir: Vector3 = desiredVec.normalized()
	var desiredSpeed = desiredVec.length()
	
	
	#update our failsafe modifiers, and also check for crouchslides.
	#might be weird to have these two be lumped in one but that's because 
	#this was the code that acted as a state-based speed limit
	#It is now in the hands of friction code and player input code.
	var curMax = walkSpeed;
	
	#crouch/sprint code here
	
	curMax +=1 #give some wiggle room
	
	#failsafe for limiting player speed. This rarely happens, but it's a quite beign fix.
	if desiredSpeed !=0.0 and desiredSpeed > curMax:
		desiredVec *= curMax / desiredSpeed # update our vector to not be too silly
		desiredSpeed = curMax # clamp it

	
	desiredVec.y = 0; #zero out the y
	
	do_Accl(desiredDir, desiredSpeed, delta)

	#deal with friction
	handle_Fric(delta)


func do_Accl(desiredDir: Vector3, desiredSpeed, delta):
	var currentspeed = sylphVel.dot(desiredDir) # are we changing direction?
	var addedspeed = desiredSpeed - currentspeed # reduce by amount
	
	if addedspeed <= 0: #no need to do anything
		return
	
	var acelspeed = 5 * delta * desiredSpeed #accelerate (worlds worst named variable) was 5
	sylphVel.y -= 60 * delta #gravamount was 60
	
	for i in range(3): 
		sylphVel += acelspeed * desiredDir

	sylphSpeed = sylphVel.length() # update playerspeed

func handle_Fric(delta):
	if sylphSpeed <= 0:
		return
	var speedThreshold = 5 #formerly stopspeed and also kinda control. If too high, won't work, if too low, will severly limit speed
	var speedFactor = 1 # how much do we want the player's speed to come into play? control in quake movement
	
	if(sylphSpeed > speedThreshold):
		speedFactor = sylphSpeed / speedThreshold

	var drop = 60 * delta * speedFactor #friction was 60
	var newspeed = sylphSpeed - drop # scale the velocity
	
	if newspeed < 0:
		newspeed = 0
	
	if newspeed != sylphSpeed:
		newspeed /= sylphSpeed # Determine proportion of old speed we are using.
		sylphVel *= newspeed# Adjust velocity according to proportion.
		sylphSpeed = sylphVel.length()
