class_name SPRINGTAIL extends CharacterBody3D



@onready var ourRoot = $".."
@onready var ourModel = $Skeleton3D/springtail_001
@onready var ourHealth:HEALTHHOLDER = $HEALTHHOLDER
@onready var casterL = $Senses/rayL
@onready var casterR = $Senses/rayR
@onready var casterC = $Senses/rayCenter
@onready var areaR = $Senses/triangleR
@onready var areaL = $Senses/triangleL


enum SpringtailState{
	DISABLED,
	WANDER, #walk randomly, try to group up
	TURN, #substate of wander: don't move anywhere, just turn to desiredOrient
	NAVING # navigating to currentDest
}

var ourState = SpringtailState.DISABLED

@export var turnSpeed = 80 ##How quickly do we turn? in mystery meat delta-corrected units
@export var runSpeed = 3 ##How quickly do we move? in mystery meat delta-corrected units
var heartBeat = 100 ##looping value for sporadic behaviors
var ourHandedness = turnSpeed ##do we favor turning left or right?
var didGroup:bool = false ##Have we tried to cohese this heartbeat yet?

#turning variables
var previousState:SpringtailState ##State before we were turning
var desiredOrient:float = 0 ##Desired angle of rotation, in radians
var orientProgress:float = 0 ##lerp value for how far along we are in the turn. primed by setup_turn()

#pathing variables
var currentDest:Node3D
@onready var visualizeMesh = $Senses/CompassRoseMesh

func _ready() -> void:
	
	#instantiate a random candy color for our delicious gummy animals
	var ourMaterial = ourModel.get_active_material(0).duplicate()
	var colors = [Color.DARK_TURQUOISE, Color.DARK_ORCHID, Color.GREEN, Color.HOT_PINK, 
	Color.ORANGE_RED, Color.YELLOW, Color.CRIMSON, Color.RED, Color.MEDIUM_SEA_GREEN,
	Color.AQUA, Color.DODGER_BLUE, Color.TOMATO]
	ourMaterial.albedo_color = colors[randi_range(0, colors.size()-1 )]
	ourMaterial.albedo_color.a = 0.5
	ourModel.material_override = ourMaterial
	
	if(Globalscript.prob(50)): 
		ourHandedness *= -1
	
	#ensure there's no fucky transforms on our root
	if(ourRoot.rotation.y != 0):
		rotation.y = ourRoot.rotation.y
		ourRoot.rotation.y = 0
	

func interact_By_Player(player):
	if(ourRoot.navNode && ourState == SpringtailState.WANDER):
		print("Attempting to path to a nav node")
		currentDest = ourRoot.navNode
		ourState = SpringtailState.NAVING
		return
	
	ourState = SpringtailState.WANDER
	print("hello i am springtail")


func hit_By_Bullet(damInfo:DAMINFO):
	
	var remaining = ourHealth.take_DamInfo(damInfo)
	if(remaining <= 0):
		springTailDie(damInfo)
	

func springTailDie(lethalDamInfo):
	print("Springtail am die")
	#todo: initialize a floating phyx object that gets YEETED the direction of lethalDamInfo,
	#reuse decal trigonometry code for this.
	ourRoot.queue_free()

var ourForwards: Vector3

##Get function for other springtails. Gives bearing in RADIANS
func get_bearing():
	return rotation.y

func _physics_process(delta: float) -> void:
	
	if(ourState == SpringtailState.DISABLED):
		return
	
	elif(ourState == SpringtailState.WANDER):
		do_wander(delta)
	elif(ourState == SpringtailState.TURN):
		do_turn(delta)
	elif(ourState == SpringtailState.NAVING):
		do_navigate(delta)
		
	move_and_slide()
	#velocity = ()

func do_wander(delta):
	#check for terrain
	var castL = casterL.get_collider()
	var castR = casterR.get_collider()
	var castC = casterC.get_collider()
	
	
	ourForwards = Vector3.FORWARD.rotated(Vector3.UP, rotation.y).normalized() * runSpeed
	##PROBLEM: springtail CAN be running straight into shit.
	
	if(castC): #if there's a wall, turn around
		ourForwards *= -1
		desiredOrient = rotation.y + (PI/2) + randf_range(-0.34, 0.34)
		if(Globalscript.prob(50)):
			desiredOrient *= -1
		setup_turn(desiredOrient)
		
	else:
		if(castL && castR): #if we're facing a wall and we havent hit it yet, turn slowly
			rotation_degrees.y += ourHandedness * delta
		if(castL):
			rotation_degrees.y -= 80 * delta
		elif (castR): 
			rotation_degrees.y += 80 * delta
	
	velocity = ourForwards
	
	#Heartbeat code; ensures we don't do complex computation every frame by running a tiny clock
	heartBeat -= 200*delta
	if(heartBeat <= 1):
		heartBeat = 100
		didGroup = false
	
	if(didGroup == false && heartBeat > 50 && heartBeat < 55):
		#keep our rotation between the bounds of -2pi, 2pi
		if(rotation.y > 2*PI):
			rotation.y -= 2*PI
		if(rotation.y < -2*PI):
			rotation.y +=2*PI
		
		#scan for springtails to pack up with
		var groupL = areaL.get_overlapping_bodies()
		var groupR = areaR.get_overlapping_bodies()
		
		#look for others in front of us, try to match up our angles
		for curItem in groupL:
			checkSpringtail_Follow(curItem)
		for curItem in groupR:
			checkSpringtail_Follow(curItem)
		
		
			
		didGroup = true

##Vets other, checks if it's a springtail, and if so, whether or not we ought to follow it
func checkSpringtail_Follow(other):
	if!(other is SPRINGTAIL):
		return
	if(other == self):
		return
	
	#if the other springtail has a destination in mind
	if(other.ourState == SpringtailState.NAVING):
		# and we don't
		if(ourState == SpringtailState.WANDER):
			ourState = SpringtailState.NAVING #follow them for a little bit
			currentDest = other.currentDest
	
	setup_turn((other.get_bearing() + rotation.y)/2)

##sets up our tracking values to successfully execute springtail turn
func setup_turn(angle:float):
	
	if(ourState == SpringtailState.TURN): #different behavior for if we're already turning
		orientProgress = 0
		desiredOrient = angle
		return
	
	orientProgress = 0
	desiredOrient = angle
	previousState = ourState
	ourState = SpringtailState.TURN

#the lerp here should probably be vetted
func do_turn(delta):
	rotation.y = lerpf(rotation.y, desiredOrient, orientProgress)
	orientProgress +=delta
	
	#accept a range of values to stop turning
	if((rotation.y <= desiredOrient + 0.05) && (rotation.y >= desiredOrient - 0.05)) || orientProgress>1:
		ourState = previousState

##Much like wander, though periodically checks for currentDest and heads that direction. Wanders when it reaches the destination.
func do_navigate(delta):
	
	#only wander AFTER, to create "leading" behaviors. Though isn't "grouping" done on the 50?
	do_wander(delta)
	
	#do the "beat" on the 100s, since the value will be set to that upon a reset
	if(heartBeat == 100):
		if(!currentDest): #in the future, change this to use array of destinations
			print("No current desination!")
			ourState = SpringtailState.WANDER
			return
		#print("nagivate heartbeat active!")
		#check to see how far we are from our target
		var theDistance = (currentDest.global_position - global_position).length()
		if(theDistance <=1):
			print("Sucessfully navigated!")
			
			#when we're doing arrays, succeed currentDest with the next in the array
			currentDest = null
			ourState = SpringtailState.WANDER
			return
		
		var newAngle = get_nav_angle(currentDest)
		#roll a chance to stray just a little off course
		if(Globalscript.prob(10)):
			newAngle += Globalscript.better_Randf_Simple(2,0,4)
		setup_turn(newAngle)
		
	
		


##finds and returns the correct bearing, in radians, to navPos
func get_nav_angle(navPos):
	#Pezza: "An elegant and simple way to orient an object, is to apply a rotation proportional, to 
	#the dot product between the target direction and the current heading's normal"

	var newY = rotation.y
	#now I know what you're thinking: why the loop?
	#we should be able to find the angle we need to turn by and just return that, right?
	#and for 90% of the time, that's true
	#but I noticed that it'll sometimes take 2-3 new calls for the angle to be correct. 
	#I could probably spend an hourish debugging, but this works fine
	
	for x in range(3):
		#this works well, in relative terms. If the springtail has any rotation, it doesn't, though.
		var targHeading = navPos.global_position - global_position 
		#the heading is absolute, but we want to localize it, so let's undo our current rotation
		targHeading.y = 0
		var theDist = targHeading.length()
		targHeading = targHeading.rotated(Vector3.UP, -newY)
		targHeading = targHeading.normalized() #normalize to dot it later
		visualizeMesh.position = targHeading
		
		
		#also, i'm realizing that we don't really want to use the dot product here. Instead, find the angle and 
		#turn to that, then resume ordinary springtail activities
			##I'm  not exactly sure why we wouldn't need to account for our current rotation, but
			##we don't actually need to.
			#var ourPerp = Vector3.LEFT
			#var theDot = targHeading.dot(ourPerp)
			##the dot product will be 0 if we are facing towards/away from the target
			##1 if we are to the left, and -1 if we are to the right
		
		var ourHeading = Vector3.FORWARD#.rotated(Vector3.UP, rotation.y)
		#print(targHeading)
		
		#the formula is a.b / ||a|| * ||b|| but since everything is normalized we can ignore the denominator
		var theta = acos(ourHeading.dot(targHeading)) + newY #- PI/2
		if(newY == theta): #stop the loop early
			break
		newY = theta
		
	return newY
	
	
	#ourState = SpringtailState.DISABLED
