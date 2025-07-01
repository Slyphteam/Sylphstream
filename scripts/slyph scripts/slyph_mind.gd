extends Node
#
@onready var body = $".."
@onready var manager: SYLPHINVENMANAGER = $"../sylph head v2/sylphinventory"

var aimSensitivity:float = 1 ##fractional multiplier
var ourNetwork:NNETWORK
var mindEnabled = false
var actionsEnabled = false
var activeTime:int = 100 #about 10 seconds

var microPenalty = 0 ##Vision-based penalty

var sensoryInput:Array ##Array of all senses
var desiredActions:Array ##Array of all desired actions

func _ready():
	initialize_Basic_Network()
	sensoryInput.resize(20)
	sensoryInput.fill(0)
	
	desiredActions.resize(18)
	desiredActions.fill(0)


func initialize_Basic_Network():
	ourNetwork = NNETWORK.new()
	print("Created basic 20-20-18 network!")
	ourNetwork.initialize_Network([20,20,18])

##Creates a new network and fully randomizes it
func initialize_Rand_Network():
	#pass
	#ourNetwork = NNETWORK.new()
	#2 inputs: target in left and target in right
	#3 nodes in the hidden layer because idk
	#3 nodes in the output layer: move left, move right, shoot
	#ourNetwork.initialize_Network([2,4,2])
	#ourNetwork.populate_Network_Rand()
	print("NETWORK RANDOMIZATION DOESNT WORK YET")
	#print("Sylph neural network sucessfully instantiated from random!")

##Saves to specified file
func save_To_File(fileString):
	ourNetwork.save_Network_To_File(fileString)
	print("Save to file complete!")

##Loads from specified file
func load_From_File(fileString):
	ourNetwork.load_Network_From_File(fileString)
	print("Load from file complete!")

##Sets the Sylph up to activate for a period of time
func begin_Test():
	print("Starting test!")
	mindEnabled = true
	activeTime = 400

##Calculates score from target based on total hits, penalty for weird movement, and penalty for firing when empty.
func score_Performance(ourTarget, hitMultiplier, missDivisor, 
					  missAllowance, goodhitsReward, visionDivisor)-> Array[int]:
	var totalHits = ourTarget.totalHits #grab the total shots taken
	
	manager.startReload() #reload the gun (this will also grab the total shots)
	var totalShots = manager.totalShots #collect the shots taken
	manager.refreshShots() #clear it
	
	var score = totalHits * hitMultiplier
	
	
	print("HEY DOOFUS MAKE SURE IT MISSES + TRACKS SHOTS MADE", totalShots) 
	
	var totalMiss = totalShots - totalHits 
	
	if(totalMiss <= missAllowance): #if we're in acceptable misses, give a reward
		score += goodhitsReward
			
	if(totalMiss > 0 && missDivisor > 0): #don't bother calculating unless there actually were misses
		score -= totalMiss / missDivisor
		pass
	
	
	if(visionDivisor > 0): #if we're doing penalties for not looking at target
		score-= int(microPenalty / visionDivisor)
	
	
	ourTarget.totalHits = 0
	microPenalty = 0
	return [totalHits, score]



func _process(_delta):
	if(mindEnabled):
		do_Single_Thought()
		activeTime-=1
		if(activeTime <=0):
			mindEnabled = false
			print("All done!")
			
			#reset
			body.unshoot_Wep()
			body.sylphHead.rotation.y = 0
			

 

func do_Single_Thought():
	
	sensoryInput = do_Senses() #gather information
	desiredActions = ourNetwork.calc_Outputs_Network(sensoryInput) #process information
	process_Actions(desiredActions) #execute actions

var aimingSights: bool = false
var modeData: Array[float] = [0.0,0.0,0.0,0.0]

func process_Actions(desiredActions:Array[float]):
	
	#print("Desired actions:", desiredActions)
	
	#INDEX 0,1: LEFT/RIGHT, UP/DOWN
	
	var leftRight = desiredActions[0] * 3 * aimSensitivity ##max per-frame movement is 3 degrees
	var upDown = desiredActions[1] * 3 * aimSensitivity ##Max per-frame movement is 3 degrees
	

	if(upDown > -0.2 && upDown < 0.2): #ignore obnoxiously small inputs
		upDown = 0
	if(leftRight > -0.2 && leftRight < 0.2):
		leftRight = 0
	
	var magnitudePenalty = Vector2(leftRight, upDown).length()
	#microPenalty += magnitudePenalty
	
	body.move_Head(Vector2(upDown,leftRight), magnitudePenalty)
	
	#INDEX 2: SHOOT OR NOT (formerly belonged to index 1)
	
	if(desiredActions[2] > 0.5):
		manager.doShoot()
	else:
		manager.unShoot()
	
	#INDEX 3: RELOAD
	if(desiredActions[3] > 0.5):
		manager.startReload()
	
	#INDEX 4: ADS
	if(desiredActions[4] > 0.5):
		if(aimingSights):
			manager.toggleSights()
			aimingSights = false
			aimSensitivity = 1 
			
		else:
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
	#if this doesnt happen things will be BAD

	#INDEX 6: AIM AZIMUTH
	#between 90 and -90
	var head = $"../sylph head v2"
	sensoryInput[6] = head.rotation_degrees.x / 90
	
	#INDEX 7: AMMO LEFT
	sensoryInput[7] = manager.get_Ammo_Left()
	
	#INDEX 8: CROSSHAIR SIZE
	sensoryInput[8] = manager.get_Crosshair_Inaccuracy()
	print(sensoryInput[8])

	#INDEX 9: AIMSPEED
	
	#INDEX 10: TARGETS PRESENT
	
	#INDEX 11: HEARTBEAT, RANDOM NOISE
	
	#INDEX 12: HEALTH
	
	#INDEX 13,14,15,16: MODAL INPUTS
	
	#INDEX 17,18,19: EXTRAS
	#TOTAL: 20
	
	#if((sensoryInput[0] == 0 )&& (sensoryInput [1] == 0)):
		
	
	#sensoryInput.append(randf_range(-1, 1))
	##print(manager.get_Ammo_Left())
	#sensoryInput.append(manager.get_Ammo_Left())

	#manager.get_Ammo_Left())
	#print("Sensory inputs: ", sensoryInput)

##Gathers vision info and updates the first 6 elements of sensoryInput
func do_Vision():
	
	print("starting vision")
	
	#var res:Array[float]
	#var left = 0

	var targetTrue:Node3D
	var targetL = get_Vision_Targets(visionL)
	if(targetL):
		targetTrue = targetL
		sensoryInput[0] = 1.0
	else:
		sensoryInput[0] = 0
	
	var targetR = get_Vision_Targets(visionR)
	if(targetR):
		targetTrue = targetR
		sensoryInput[1] = 1.0
	else:
		sensoryInput[1] = 0
	
	var targetU = get_Vision_Targets(visionU)
	if(targetU):
		targetTrue = targetU
		sensoryInput[2] = 1.0
	else:
		sensoryInput[2] = 0.0
	
	var targetD = get_Vision_Targets(visionD)
	if(targetD):
		targetTrue = targetD
		sensoryInput[3] = 1.0
	else:
		sensoryInput[3] = 0.0
	
	#next, do the "extrema"
	if(!targetTrue): #we do not have a target anywhere in sight, you get no awareness, bwomp bwomp
		sensoryInput[4] = 0
		sensoryInput[5] = 0
		
		#in fact, Im going to penalize you for not being able to see a target
		if(targetsPresent != 0):
			microPenalty +=1 
		
	else:
		
		#issue: targetTrue is the staticbody that gets detected, and has a transform of 0.
		#solution: just use globals?
		var connectingVec = targetTrue.global_position - body.global_position
		var pos1 = targetTrue.global_position
		var pos2 = body.global_position
		#print("connecting vec: ",connectingVec)
		#since the sylph probably won't care about the exact degrees and what the basis/origin is,
		#I'm not going to be bothering with being too fancy about it.
		if(absf(connectingVec.z)<0.01):
			connectingVec.z = 0
		
		var theta = atan(connectingVec.x/connectingVec.z)
		#print("target's theta:", theta)
		
		#So, what does theta actually mean?
		#it's the radians of rotation relative to a global basis that isn't actually important, since
		#it's consistent, again, globally. I REALLY hope.
		#exactly head on is 1.5 to the left and -1.5 to the right
		#then it goes down to about 1.08 at most on either side.
		#we'll be generous and say it has a range of about 0.45
		#I also don't entirely trust the sylphs to deal with the cup shape AND the negative flip
		#and they're already being told which way the target is, I don't think it's useful.
		#therefore, I am only going to use this as a way to tell them the EXTREMA of the angle
		
		#print("raw theta:", theta)
		theta = absf(theta)
		
		theta = 1.05-theta
		
		#theta now is between -0.08 and -0.5
		#add 0.05 to mostly nullify out the offset
		theta += 0.05
		#multiply it by 4 to make it between 0ish and 2ish
		theta *=4
		#make it absolute
		theta = absf(theta)
		#subtract 1 to make it between mostly -1 and 1
		theta -=1
		
		#is -1 and 1 better or worse than 0-1? absolutely no idea lmao.
		sensoryInput[4] = theta
		
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
	
	ourNetwork.mutate_Network(10, 0)
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
