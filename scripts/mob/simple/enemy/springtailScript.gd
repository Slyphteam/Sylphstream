class_name SPRINGTAIL extends CharacterBody3D

enum SpringtailState{
	DISABLED,
	WANDER,
	TURN
}

@onready var ourRoot = $".."
@onready var ourModel = $Skeleton3D/springtail_001
@onready var ourHealth:HEALTHHOLDER = $HEALTHHOLDER
@onready var casterL = $Senses/rayL
@onready var casterR = $Senses/rayR
@onready var casterC = $Senses/rayCenter
@onready var areaR = $Senses/triangleR
@onready var areaL = $Senses/triangleL

var heartBeat = 100
var ourState = SpringtailState.DISABLED
@export var turnSpeed = 80
@export var runSpeed = 3
var ourHandedness = turnSpeed

var desiredOrient:float = 0
var orientProgress:float = 0

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
	ourState = SpringtailState.WANDER
	print("hello i am springtail")
	print(ourForwards)

var lastDam:DAMINFO
func hit_By_Bullet(damInfo:DAMINFO):
	
	var remaining = ourHealth.take_DamInfo(damInfo)
	if(remaining <= 0):
		springTailDie()
	

func springTailDie():
	print("Springtail am die")
	#todo: initialize a floating phyx object that gets YEETED the direction of lastDamDirection,
	#reuse decal trigonometry code for this.
	ourRoot.queue_free()

var ourForwards: Vector3

#gives bearing in RADIANS
func get_bearing():
	return rotation.y

func _physics_process(delta: float) -> void:
	
	if(ourState == SpringtailState.DISABLED):
		return
	
	elif(ourState == SpringtailState.WANDER):
		do_wander(delta)
	elif(ourState == SpringtailState.TURN):
		do_turn(delta)
		
	move_and_slide()
	#velocity = ()

func do_wander(delta):
	#check for terrain
	var castL = casterL.get_collider()
	var castR = casterR.get_collider()
	var castC = casterC.get_collider()
	
	
	ourForwards = Vector3.FORWARD.rotated(Vector3.UP, rotation.y).normalized() * runSpeed
	##PROBLEM: springtail CAN be running straight into shit.
	
	if(castC): #extra cast, transition to new state
		
		ourState = SpringtailState.TURN
		orientProgress = 0
		ourForwards *= -1
		desiredOrient = rotation.y + (PI/2) + randf_range(-0.34, 0.34)
		if(Globalscript.prob(50)):
			desiredOrient *= -1
		
	else:
		if(castL && castR): #if we're facing a wall, turn around
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
		
		#clean up our values
		if(rotation.y > 2*PI):
			rotation.y -= 2*PI
		if(rotation.y < -2*PI):
			rotation.y +=2*PI
		
		
		#scan for springtails to pack up with
		var groupL = areaL.get_overlapping_bodies()
		var groupR = areaR.get_overlapping_bodies()
		
		#look for others in front of us, try to match up our angles
		for curItem in groupL:
			if(curItem is SPRINGTAIL):
				desiredOrient = (curItem.get_bearing() + rotation.y*randf_range(0.6, 0.9) )/2
				ourState = SpringtailState.TURN
				orientProgress = 0
		for curItem in groupR:
			if(curItem is SPRINGTAIL):
				desiredOrient = (curItem.get_bearing() + rotation.y*randf_range(0.6, 0.9) )/2
				ourState = SpringtailState.TURN
				orientProgress = 0

func do_turn(delta):
	
	
	rotation.y = lerpf(rotation.y, desiredOrient, orientProgress)
	orientProgress +=delta
	
	#accept a range of values to stop turning
	if((rotation.y <= desiredOrient + 0.05) && (rotation.y >= desiredOrient - 0.05)) || orientProgress>1:
		ourState = SpringtailState.WANDER
