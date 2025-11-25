extends Node

@onready var body = $".."
@onready var manager: SYLPHINVENMANAGER = $"../sylph head v2/sylphinventory"
@onready var ourHP: HEALTHHOLDER = $"../COMPLEXHEALTHHOLDER"

var aimSensitivity:float = 1 ##fractional multiplier

var ourTarget
var mindEnabled = false
var activeTime:int = 0 ##about 400
var microPenalty = 0 ##Vision-based penalty. Shouldn't this be in the trainer??



#Shooting network. 
var shootingNetwork:NNETWORK
var shootingInput:Array[float] #Inputs: U,D,L,R,C vision components, random, current spread, azimuth, offset
var shootingActions:Array[float] #Outputs: Shoot, updown, leftright

var inputSize = 11

#var sensoryInput:Array[float] ##Array of all senses
#var desiredActions:Array[float] ##Array of all desired actions


func do_Debug_Action():
	#print("Wow! You called my debug testing function")
	
	#var inputData:Array[float] = [1,1,1,1,1,1,1,1]
	#var outputData = shootingNetwork.get_Layer(0).calc_Outputs(inputData)
	#print(outputData)
	#var output2 = shootingNetwork.get_Layer(1).calc_Outputs(outputData)
	#print(output2)
	#print("done?")
	
	
	#shootingNetwork.print_Network()
	print("Doing pulse mutation!")
	
	shootingNetwork.mutate_Pulse(1, 0, 2, 50)
	shootingNetwork.print_Network()

func _ready():
	
	initialize_Basic_Networks() #kind of wasteful but id rather the networks ALWAYS exist than not.
	shootingInput.resize(inputSize)
	shootingInput.fill(0)
	
	shootingActions.resize(4)
	shootingActions.fill(0)
	Globalscript.add_Sylph(self)
	
	ourTarget = body.ourTar
	#load_From_File("res://resources/txt files/sylph tests/multi evolution test/startingpoint.txt")


func initialize_Basic_Networks():
	
	shootingNetwork = NNETWORK.new()
	shootingNetwork.initialize_Network([inputSize, 8, 6, 4])
	
	#print("Created Basic S")

##Creates a new network and fully randomizes it
func initialize_Rand_Networks():
	
	shootingNetwork = NNETWORK.new()
	shootingNetwork.initialize_Network([inputSize, 8, 6, 4])
	shootingNetwork.populate_Network_Rand()
	
	print("Created random Splylph network!")

##Saves to specified folder, with a given suffix
func save_Nets_To_Folder(fileString:String, suffix: String):
	shootingNetwork.save_Network_To_File(fileString + "SHOOT" + suffix + ".txt")
	print("Save to file complete!")

##Loads from specified file
func load_Nets_From_Folder(fileString, suffix: String):
	shootingNetwork.load_Network_From_File(fileString+ "SHOOT" +suffix +".txt")
	print("Load from file complete!")

##Deep copies neural network from other sylphbody
func copy_From_Other(otherSylph):
	
	if(otherSylph.ourNetwork):
		print("Tried to copy mind of a non-fragmentary sylph!")
		return
	shootingNetwork.copy_From_Other(otherSylph.shootingNetwork)

##Sets the Sylph up to activate for a period of time
func begin_Test():
	mindEnabled = true
	activeTime = 1200

##Calculates score from target based on total hits, penalty for weird movement, and penalty for firing when empty.
func score_Performance(hitMultiplier, missDivisor, 
					  missAllowance, goodhitsReward, visionDivisor)-> Array[int]:
	
	
	
	var totalHits = ourTarget.totalHits #grab the total shots taken
	
	manager.grabShots()
	var totalShots = manager.totalShots #collect the shots taken
	manager.startReload() #reload the gun 
	
	#print(totalHits, " micro ", microPenalty, " shots ", totalShots)
	
	var score = totalHits * hitMultiplier
	
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
	microPenalty = 0
	body.sylphHead.rotation.y = 0
	body.sylphHead.rotation.x = 0
	manager.refreshShots() #clear it

func _process(delta):
	if(mindEnabled):
		do_Single_Thought(delta)
		activeTime-=1
		
		if(activeTime <=0):
			mindEnabled = false
			manager.unShoot() #prevent the sylph from ever turning off in a shoot mode, which would be unfair

func do_Single_Thought(delta):
	do_Senses() #gather information
	#do shooting
	shootingActions = shootingNetwork.calc_Outputs_Network(shootingInput) #process information
	process_Shooting_Actions(delta) #execute actions

var aimVector: Vector2
var aimingSights: bool = false
var modeData: Array[float] = [0.0,0.0,0.0,0.0]
var maxSpeed = 3 

func process_Shooting_Actions(delta): #total of 4
	
	#print("Desired actions:", desiredActions)
	
	#INDEX 0,1: LEFT/RIGHT, UP/DOWN
	
	#what are the bounds of outputs? they seem to be in the teens. 
	
	#why?????
	for x in shootingActions.size():
		shootingActions[x] /= 0.7 
	
	var deltaScalar = 60 * delta
	var leftRight = shootingActions[0] * aimSensitivity * deltaScalar ##max per-frame movement is 3 degrees
	var upDown = shootingActions[1] * aimSensitivity * deltaScalar ##Max per-frame movement is 3 degrees
	
	#Index 2: STOP
	var mouseStop = shootingActions[2]
	if(mouseStop > 0.8):
		leftRight *=  1 - mouseStop + 0.4
		upDown *= 1 - mouseStop + 0.4

	
		#add friction
	aimVector *= 0.7 #does this work?
	aimVector += Vector2(leftRight, upDown) 
	
	#microPenalty += Vector2(desiredActions[0], desiredActions[1]).length() / 3
	

	
	#inaccuracy currently disabled
	#if(speed >= 2.2):
		#var inaccuracy = Vector2(randf_range(-0.01, 0.01), randf_range(-0.01, 0.01)) * speed
		#aimVector += inaccuracy
	#starting out with 3 max rotation speed
	maxSpeed = 3 * deltaScalar
	aimVector.x = clampf(aimVector.x, -maxSpeed, maxSpeed)
	aimVector.y = clampf(aimVector.y, -maxSpeed, maxSpeed)



	body.move_Head_Exact(aimVector)
	
	#INDEX 3: SHOOT OR NOT (formerly belonged to index 1)
	if(shootingActions[3] > 0.5):
		manager.doShoot()
	else:
		manager.unShoot()
	

@onready var visionR: Area3D = $"../sylph head v2/senses/vision/triangleR"
@onready var visionL: Area3D = $"../sylph head v2/senses/vision/triangleL"
@onready var visionU: Area3D = $"../sylph head v2/senses/vision/triangleU"
@onready var visionD: Area3D = $"../sylph head v2/senses/vision/triangleD"
var targetsPresent = 1 #assume there's a target.

#SHOOTING INPUT:
#0,1,2,3: DIRECTIONAL SENSES
#4,5,: DISTANCE, EXTREMA
# 6: AIM AZIMUTH, 7: CROSSHAIR SIZE, 8: AIMSPEED, 9: RANDOM

#gathers sensory info and updates the sensoryInput array
func do_Senses():
	

	#INDEX 0,1,2,3 AND 4,5 of SHOOTING
	var targetTrue:Node3D
	var targetL = get_Vision_Targets(visionL)
	if(targetL):
		targetTrue = targetL
		shootingInput[0] = 1.0
	else:
		shootingInput[0] = 0
		microPenalty +=1
	
	#INDEX 1: RIGHT
	var targetR = get_Vision_Targets(visionR)
	if(targetR):
		targetTrue = targetR
		shootingInput[1] = 1.0
	else:
		shootingInput[1] = 0
		microPenalty +=1
	
	#INDEX 2: UP
	var targetU = get_Vision_Targets(visionU)
	if(targetU):
		targetTrue = targetU
		shootingInput[2] = 1.0
	else:
		shootingInput[2] = 0.0
		microPenalty +=1
	
	#INDEX 3: DOWN
	var targetD = get_Vision_Targets(visionD)
	if(targetD):
		targetTrue = targetD
		shootingInput[3] = 1.0
	else:
		shootingInput[3] = 0.0
		microPenalty +=1
	
	if(!targetTrue): #we do not have a target anywhere in sight, you get no awareness, bwomp bwomp
		shootingInput[4] = 1 #INDEX 4: EXTREMA (actually max awareness)
		shootingInput[5] = 1 #INDEX 5: DISTANCE
		
	else:
		
		var bodpos = body.global_position
		var tarpos = targetTrue.global_position
		bodpos.y = 0 #ignore vertical differences. (no way this causes problems later, right?)
		tarpos.y = 0 
		var connectingVec = bodpos - tarpos
		
		#print("connecting vec: ",connectingVec)
		#since the sylph probably won't care about the exact degrees and what the basis/origin is,
		#I'm not going to be bothering with being too fancy about it.
		if(absf(connectingVec.z)<0.01):
			connectingVec.z = 0
			
		#INDEX 5: DISTANCE
		shootingInput[5] = (connectingVec.length() / 12.5) -1 
		
		#INDEX 4: EXTREMA
		var sylphVisCenter: Vector2 
		sylphVisCenter = Vector2(connectingVec.length(), 0)
		sylphVisCenter = sylphVisCenter.rotated(body.sylphHead.rotation.y)
		sylphVisCenter += Vector2(bodpos.x, bodpos.z)
		
		var diff = sylphVisCenter - Vector2(tarpos.x, tarpos.z)
		var offset = diff.length() #tentative max for offset is 12.3
		
		offset /= 6.15
		offset -=1
		shootingInput[4] = offset
	

	#INDEX 6: AIM AZIMUTH
	#between 90 and -90
	var head = $"../sylph head v2"
	shootingInput[6] = 0#head.rotation_degrees.x / 90
	
	
	#INDEX 7: CROSSHAIR SIZE
	shootingInput[7] = manager.get_Crosshair_Inaccuracy()
	#if(sensoryInput[8] >= -0.74):
		#print("Crosshair size:", sensoryInput[8])

	#INDEX 8: AIMSPEED
	var speed = aimVector.length()
	#equal to the hypotenuse of a iscoceles right triangle (with friction applied)
	var highestPossibleSpeed = sqrt(4 * maxSpeed * maxSpeed) * 0.7
	var adjustedSpeed:float = speed / highestPossibleSpeed
	#print(speed, " ", highestPossibleSpeed)
	shootingInput[8] = adjustedSpeed
	
	#INDEX 9+10: MOTIONS
	shootingInput[9] = 0#randf_range(-0.05, 0.05)
	shootingInput[10] = 0



##returns the target, if any exist in a visionblock, or false.
func get_Vision_Targets(visionBlock:Area3D):
	if(visionBlock.has_overlapping_bodies()):
		var items = visionBlock.get_overlapping_bodies()
		var x:int = 0
		while(x < items.size()):
			if(items[x].is_in_group("sylph_target")):
				return items[x]
			x+=1
	return false

# moved this to network class
#func mutation_Test(val:float):
	#
	#print("Before mutation:")
	#print(ourNetwork.get_Layer(1).weights[0])
	#print(ourNetwork.get_Layer(1).weights[1])
	#print(ourNetwork.get_Layer(1).weights[2])
	#
	#ourNetwork.mutate_Network(10, 0, 50)
	##UHOH!!!! DIDNT DO THEM ALL!!!
	#print("After mutation:")
	#print(ourNetwork.get_Layer(1).weights[0])
	#print(ourNetwork.get_Layer(1).weights[1])
	#print(ourNetwork.get_Layer(1).weights[2])
