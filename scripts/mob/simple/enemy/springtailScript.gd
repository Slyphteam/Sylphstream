extends CharacterBody3D

enum SpringtailState{
	DISABLED,
	WANDER
}

@onready var ourRoot = $".."
@onready var ourModel = $Skeleton3D/springtail_001
@onready var ourHealth:HEALTHHOLDER = $HEALTHHOLDER
@onready var casterL = $Senses/rayL
@onready var casterR = $Senses/rayR

#var heartBeat = 10
var ourState = SpringtailState.DISABLED
@export var turnSpeed = 80
var ourHandedness = turnSpeed


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

var lastDamDirection
func hit_By_Bullet(dam, _damtype, dir, _entity):
	lastDamDirection = dir
	print(lastDamDirection)
	print(_damtype)
	print(_entity)
	print(dam)
	ourHealth.take_Dam(dam)
	pass

func doDie():
	print("I am die")
	#todo: initialize a floating phyx object that gets YEETED the direction of lastDamDirection,
	#reuse decal trigonometry code for this.
	ourRoot.queue_free()

var ourForwards: Vector3

func _physics_process(delta: float) -> void:
	
	if(ourState == SpringtailState.DISABLED):
		return
	
	#Heartbeat code; ensures we don't do complex computation every frame by running a tiny clock
	#heartBeat -= 600*delta
	#if(heartBeat >= 1):
		#return
	#heartBeat = 80
	
	#check for terrain
	var castL = casterL.get_collider()
	var castR = casterR.get_collider()
	
	if(castL && castR): #if we're facing a wall, turn around
		rotation_degrees.y += ourHandedness * delta
	elif(castL):
		rotation_degrees.y -= 80 * delta
	elif (castR): 
		rotation_degrees.y += 80 * delta
	
	
	ourForwards = Vector3.FORWARD.rotated(Vector3.UP, rotation.y).normalized()
	velocity = ourForwards
	
	
	move_and_slide()
	#velocity = ()
