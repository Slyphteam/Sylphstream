extends Node

@onready var body = $".."
@onready var manager: SYLPHINVENMANAGER = $"../sylph head v2/sylphinventory"

var aimSensitivity:float = 1 ##fractional multiplier
var ourNetwork:NNETWORK
var mindEnabled = false
var activeTime:int = 0 ##about 400
var heartBeat = 100 

var microPenalty = 0 ##Vision-based penalty


var sensoryInput:Array[float] ##Array of all senses
var desiredActions:Array[float] ##Array of all desired actions

func init():
	Globalscript.add_Sylph(self)

func _ready():
	initialize_Basic_Network()
	initialize_Rand_Network()
	sensoryInput.resize(20)
	sensoryInput.fill(0)
	
	desiredActions.resize(18)
	desiredActions.fill(0)
	
	load_From_File("res://resources/txt files/sylph tests/multi evolution test/startingpoint.txt")


func initialize_Basic_Network():
	ourNetwork = NNETWORK.new()
	print("Created basic 20-20-40-30-18 network!")
	ourNetwork.initialize_Network([20,20,40,30,18])

##Creates a new network and fully randomizes it
func initialize_Rand_Network():
	ourNetwork = NNETWORK.new()
	ourNetwork.initialize_Network([20,20,40,30,18])
	ourNetwork.populate_Network_Rand()
	print("Created random 20-20-40-30-18 network!")

##Saves to specified file
func save_To_File(fileString):
	ourNetwork.save_Network_To_File(fileString)
	print("Save to file complete!")

##Loads from specified file
func load_From_File(fileString):
	ourNetwork.load_Network_From_File(fileString)
	print("Load from file complete!")

##Copies neural network from other sylphbody
func copy_From_Other(otherSylph):
	ourNetwork.copy_From_Other(otherSylph.mind.ourNetwork)

##Sets the Sylph up to activate for a period of time
func begin_Test():
	print("Starting test!")
	mindEnabled = true
	activeTime = 400

##Calculates score from target based on total hits, penalty for weird movement, and penalty for firing when empty.
func score_Performance(ourTarget, hitMultiplier, missDivisor, 
					  missAllowance, goodhitsReward, visionDivisor)-> Array[int]:
	
	
	
	var totalHits = ourTarget.totalHits #grab the total shots taken
	
	manager.grabShots()
	var totalShots = manager.totalShots #collect the shots taken
	manager.startReload() #reload the gun 
	
	print(totalHits, " micro ", microPenalty, " shots ", totalShots)
	
	var score = totalHits * hitMultiplier
	
	
	#print("HEY DOOFUS MAKE SURE IT MISSES + TRACKS SHOTS MADE", totalShots) 
	
	var totalMiss = totalShots - totalHits 
	
	if(totalMiss <= missAllowance): #if we're in acceptable misses, give a reward
		score += goodhitsReward
	else:
		score -=1 #delete this branch later
	
	if(totalMiss > 0 && missDivisor > 0): #don't bother calculating unless there actually were misses
		score -= totalMiss / missDivisor
		pass
	
	
	if(visionDivisor > 0): #if we're doing penalties for not looking at target
		score-= int(microPenalty / visionDivisor)
	
	refresh_Stats() #refresh stats
	#ourTarget.totalHits = 0 #and the target
	ourTarget.reset()
	
	return [totalHits, score]

##refreshes stats after a test
func refresh_Stats():
	manager.unShoot()
	heartBeat = 100
	microPenalty = 0
	body.sylphHead.rotation.y = 0
	body.sylphHead.rotation.x = 0
	manager.refreshShots() #clear it

func _process(delta):
	if(mindEnabled):
		do_Single_Thought(delta)
		activeTime-=1
		heartBeat-=1
		
		if(heartBeat == 0):
			heartBeat = 100
		
		if(activeTime <=0):
			mindEnabled = false
			manager.unShoot() #prevent the sylph from ever turning off in a shoot mode, which would be unfair

func do_Single_Thought(delta):
	do_Senses() #gather information
	desiredActions = ourNetwork.calc_Outputs_Network(sensoryInput) #process information
	process_Actions(delta) #execute actions

var aimVector: Vector2

var aimingSights: bool = false
var modeData: Array[float] = [0.0,0.0,0.0,0.0]

func process_Actions(delta):
	
	#print("Desired actions:", desiredActions)
	
	#INDEX 0,1: LEFT/RIGHT, UP/DOWN
	
	#what are the bounds of outputs? they seem to be in the teens. 
	
	for x in desiredActions.size():
		desiredActions[x] /= 0.7
	
	var deltaScalar = 60 * delta
	var leftRight = desiredActions[0] * aimSensitivity * deltaScalar ##max per-frame movement is 3 degrees
	var upDown = desiredActions[1] * aimSensitivity * deltaScalar ##Max per-frame movement is 3 degrees
	
		#add friction
	aimVector *= 0.7 #does this work?
	aimVector += Vector2(leftRight, upDown) 
	var speed = aimVector.length()
	
	microPenalty += Vector2(desiredActions[0], desiredActions[1]).length() / 3
	

	
	#inaccuracy currently disabled
	#if(speed >= 2.2):
		#var inaccuracy = Vector2(randf_range(-0.01, 0.01), randf_range(-0.01, 0.01)) * speed
		#aimVector += inaccuracy
	#starting out with 3 max rotation speed
	var maxSpeed = 3 * deltaScalar
	aimVector.x = clampf(aimVector.x, -maxSpeed, maxSpeed)
	aimVector.y = clampf(aimVector.y, -maxSpeed, maxSpeed)
	

	body.move_Head_Exact(aimVector)
	
	#INDEX 2: SHOOT OR NOT (formerly belonged to index 1)
	if(desiredActions[2] > 0.5):
		manager.doShoot()
	else:
		manager.unShoot()
	
	#INDEX 3: RELOAD
	if(desiredActions[3] > 0.9):
		manager.startReload()
	
	#INDEX 4: ADS
	if(desiredActions[4] > 0.5):
		if(aimingSights): #STOP aiming
			manager.toggleSights()
			aimingSights = false
			aimSensitivity = 1 
			
		else: #start aiming
			manager.toggleSights()
			aimingSights = true
			aimSensitivity = 0.6 #calculated from the player's ADS ratio of 15/25
	
	
	#INDEX 5, 6 ,7, 8: W,A,S,D
	
	#INDEX 9,10,11, CROUCH, JUMP, SPRINT
	#also not worried about this yet
	
	#INDEX 12,13,14,15 MODAL DATA
	#we don't actually do anything for modal data output/input. 
	#that's for the sylphs :)
	
	#INDEX 16,17: EXTRAS
	#we also dont do anything with this.
	#total: 18

@onready var visionR: Area3D = $"../sylph head v2/senses/vision/triangleR"
@onready var visionL: Area3D = $"../sylph head v2/senses/vision/triangleL"
@onready var visionU: Area3D = $"../sylph head v2/senses/vision/triangleU"
@onready var visionD: Area3D = $"../sylph head v2/senses/vision/triangleD"
var targetsPresent = 1 #assume there's a target.

#gathers sensory info and updates the sensoryInput array
func do_Senses():
	

	#INDEX 0,1,2,3 AND 4,5: VISION SENSES
	do_Vision()
	#keep in mind 4-5 work are trained on both sylph and target having same root.
	#if this doesnt happen things will be BAD (is this even true anymore? idk, check)

	#INDEX 6: AIM AZIMUTH
	#between 90 and -90
	var head = $"../sylph head v2"
	sensoryInput[6] = head.rotation_degrees.x / 90
	
	#INDEX 7: AMMO LEFT
	sensoryInput[7] = manager.get_Ammo_Left()
	
	#INDEX 8: CROSSHAIR SIZE
	sensoryInput[8] = manager.get_Crosshair_Inaccuracy()
	if(sensoryInput[8] <= -0.984):
		print("Crosshair size:", sensoryInput[8])

	#INDEX 9: AIMSPEED
	#not doing this yet because I haven't programmed aim inertia
	sensoryInput[9] = 0
	
	#INDEX 10: TARGETS PRESENT
	#not currently doing anything with this
	sensoryInput[10] = targetsPresent
	
	#INDEX 11: Empty!
	
	sensoryInput[11] = 0#heartCur
	
	#INDEX 12: HEALTH
	#not doing this yet
	sensoryInput[12] = 0
	
	#INDEX 13,14,15,16: MODAL INPUTS
	sensoryInput[13] = desiredActions[12]
	sensoryInput[14] = desiredActions[13]
	sensoryInput[15] = desiredActions[14]
	sensoryInput[16] = desiredActions[15]
	
	#INDEX 17, RANDOM NOISE
	sensoryInput[17] = randf_range(-0.05, 0.05)
	
	#18: DISTANCE (put this in vision function since it sort of is vision
	#sensoryInput[18] = 0

	#19: TOTAL DAMAGE DEALT
	sensoryInput[19] = 0
	#TOTAL: 20
	
##Gathers vision info and updates the first 6 elements of sensoryInput
func do_Vision():
	
	#print("starting vision")
	
	#var res:Array[float]
	#var left = 0

	var targetTrue:Node3D
	var targetL = get_Vision_Targets(visionL)
	if(targetL):
		targetTrue = targetL
		sensoryInput[0] = 1.0
	else:
		sensoryInput[0] = 0
		microPenalty +=1
	
	var targetR = get_Vision_Targets(visionR)
	if(targetR):
		targetTrue = targetR
		sensoryInput[1] = 1.0
	else:
		sensoryInput[1] = 0
		microPenalty +=1
	
	var targetU = get_Vision_Targets(visionU)
	if(targetU):
		targetTrue = targetU
		sensoryInput[2] = 1.0
	else:
		sensoryInput[2] = 0.0
		microPenalty +=1
	
	var targetD = get_Vision_Targets(visionD)
	if(targetD):
		targetTrue = targetD
		sensoryInput[3] = 1.0
	else:
		sensoryInput[3] = 0.0
		microPenalty +=1
	
	if(!targetTrue): #we do not have a target anywhere in sight, you get no awareness, bwomp bwomp
		sensoryInput[4] = -1
		sensoryInput[5] = -1
		sensoryInput[18] = 1
		
	else:
		
		
		#issue: targetTrue is the staticbody that gets detected, and has a transform of 0.
		#solution: just use globals?
		var connectingVec = body.global_position - targetTrue.global_position
		
		
		#print("connecting vec: ",connectingVec)
		#since the sylph probably won't care about the exact degrees and what the basis/origin is,
		#I'm not going to be bothering with being too fancy about it.
		if(absf(connectingVec.z)<0.01):
			connectingVec.z = 0
			
		#18: DISTANCE
		#Sylph's max vision range is currently 23, so we'll use that as our basis
		#We'll go from -1 to .90 to better differentiate it from max dist
		# therefore, our range will be 1.9 offset by 1
		#connectingvec / 23 is between 0 and 1
		var dist = (connectingVec.length() / 12.5) -1 #value between 0 and 2
		sensoryInput[18] = (connectingVec.length() / 12.5) -1 
		
		#print(connectingVec.x, " ", connectingVec.z)
		var theta : float = atan(connectingVec.z/connectingVec.x)
		#print("target's theta:", theta)
		
		var rotation = 0 - (body.sylphHead.rotation.y + body.rotation.y) #draw from both head and body rotation
		if(rotation > 3.5):
			print("rotation is too big! we havent handled this yet!")
		#print("rotation ", rotation)
		var change = theta - rotation
		 #current implementation works when sylph is facing right, but not left.
		#change is between +- 0.47
		#but we only care about the absolute.
		change = absf(change)
		change *= 2.2
		sensoryInput[5] = clampf(change, 0, 1)
		
		#I'm too lazy to do the azimuth extrema and i dont think it matters too much. soooo.
		sensoryInput[5] = 0


#returns the target, if any exist in a visionblock, or false.
func get_Vision_Targets(visionBlock:Area3D):
	if(visionBlock.has_overlapping_bodies()):
		var items = visionBlock.get_overlapping_bodies()
		var x:int = 0
		while(x < items.size()):
			if(items[x] is testing_target): #only targets for now
				return items[x]
			x+=1
	return false


func mutation_Test(val:float):
	
	print("Before mutation:")
	print(ourNetwork.get_Layer(1).weights[0])
	print(ourNetwork.get_Layer(1).weights[1])
	print(ourNetwork.get_Layer(1).weights[2])
	
	ourNetwork.mutate_Network(10, 0, 50)
	#UHOH!!!! DIDNT DO THEM ALL!!!
	print("After mutation:")
	print(ourNetwork.get_Layer(1).weights[0])
	print(ourNetwork.get_Layer(1).weights[1])
	print(ourNetwork.get_Layer(1).weights[2])

#Total inputs: 17, with 3 extra nodes
#Total outputs: 16, with 2 extra nodes
#Network architecture:
#I'm thinking a 20/20/40/30/20/18 is what we want.

#Why do I think this?
#1: second layer of input size lets there be some sensory interplay
#2: jump up to 40 is where the meat of the interaction comes from
#3: jump down to for more interaction, but not as beefy as a 40/40 interface would be
#4: jump down to 20 for a tapering effect


#Senses:
#Vision L, R, U, D (4)
#Random noise + “heartbeat” (2)
#Ammo left, Target distance, Crosshair size, aimspeed: 4
#Aim azimuth 1
#Aim extremity (L/R), (U/D) : 2
#Total: 4+2+4+1+2 = 13

#Vision directions: up, down, left, right, center.
#Will give the bulk of the input, important for aiming.
#random noise + "heartbeat": gives sylph ability to do some repetitive/random actions.
#aim azimuth: horizontal aiming is very important and I want the sylph to not get lost
#if it aims too high or too low. This will hopefully let it correct
#aim extremity: sort of just the angle of difference, will hopefully let it aim slower
#if things are closer to the center


#Exosenses:
#Targets present
#Mode A, B, C, D
#Health
#Total: 6

#Targets present: acts like a "global" threat input. 
#Modes: allows for feedback.
#health: who knows, might just allow for different behavior if the sylph is injured
#Total inputs: 17?

#no real commentary needed on outputs

#
#Outputs:
#Shoot, L/R, U/D, reload, ADS (5)
#Mode A, B, C, D (4)
#Crouch, jump, sprint (3)
#WASD: (4)

#Total outputs: 
#16?
