extends Node

@onready var body = $".."
@onready var manager: SYLPHINVENMANAGER = $"../sylph head v2/sylphinventory"
@onready var ourHP: HEALTHHOLDER = $"../COMPLEXHEALTHHOLDER"

var aimSensitivity:float = 1 ##fractional multiplier
var ourNetwork:NNETWORK
var ourTarget
var mindEnabled = false
var activeTime:int = 0 ##about 400
var heartBeat = 100 

var microPenalty = 0 ##Vision-based penalty


var sensoryInput:Array[float] ##Array of all senses
var desiredActions:Array[float] ##Array of all desired actions


#Input directory:
	#0:
	#1
	#2
	#3
	#4
	#5
	#6 Aiming
	#7 ammo
	#8 crosshair
	#9 aimspeed
	#10 Target exists? (1)
	#11 Health
	#12 Mode
	#13 Mode
	#14 Mode
	#15 Empty

#Output directory:
#change to be 0-1 "mouse" movement
#2,3: future divorced mouse movement
#4 for "stop"
#5/6/7 for shoot/ADS/reload
#8,9,10,11 for WASD
#12/13 for crouch/jump
#14,13,16 for modal

func do_Debug_Action():
	
	print("Wow! You called my debug testing function")
	#if(Globalscript.prob(50)):
		#body.move_Head_Exact(Vector2(0,20))
	#else:
		#body.move_Head_Exact(Vector2(0,-20))
	#print(body.sylphHead.rotation_degrees.x / 90)

func _ready():
	
	initialize_Basic_Network()
	sensoryInput.resize(16)
	sensoryInput.fill(0)
	
	desiredActions.resize(18)
	desiredActions.fill(0)
	
	Globalscript.add_Sylph(self)
	ourTarget = body.ourTar
	#load_From_File("res://resources/txt files/sylph tests/multi evolution test/startingpoint.txt")


func initialize_Basic_Network():
	ourNetwork = NNETWORK.new()
	#print("Created basic network!")
	ourNetwork.initialize_Network([16,20,20,18])

##Creates a new network and fully randomizes it
func initialize_Rand_Network():
	#print("Randomized network!")
	ourNetwork = NNETWORK.new()
	ourNetwork.initialize_Network([16,20,20,18])
	ourNetwork.populate_Network_Rand()
	#print("Created random 20-20-40-30-18 network!")

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
	ourNetwork.copy_From_Other(otherSylph.ourNetwork)

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
#var modeData: Array[float] = [0.0,0.0,0.0,0.0]
var maxSpeed = 3 

#change to be 0-3 for "mouse" movement
#4 for "stop"
#5/6/7 for shoot/ADS/reload
#8,9,10,11 for WASD
#12/13 for crouch/jump
#14,13,16 for modal
func process_Actions(delta):
	
	#print("Desired actions:", desiredActions)
	
	#INDEX 0,1: LEFT/RIGHT, UP/DOWN
	
	#what are the bounds of outputs? they seem to be in the teens. 
	for x in desiredActions.size():
		desiredActions[x] /= 0.7
	
	
	var deltaScalar = 60 * delta
	var leftRight = desiredActions[0] * aimSensitivity * deltaScalar ##max per-frame movement is 3 degrees
	var upDown = desiredActions[1] * aimSensitivity * deltaScalar ##Max per-frame movement is 3 degrees
	
	#Index 2,3: To be the divorced up/down
	
	#Index 4: stop
	var mouseStop = desiredActions[4]
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
	
	#INDEX 5: SHOOT OR NOT
	if(desiredActions[5] > 0.5):
		manager.doShoot()
	else:
		manager.unShoot()
	
	#INDEX 6: RELOAD
	if(desiredActions[6] > 0.9):
		manager.startReload()
	
	#INDEX 7: ADS
	if(desiredActions[7] > 0.5):
		if(aimingSights): #STOP aiming
			manager.toggleSights()
			aimingSights = false
			aimSensitivity = 1 
			
		else: #start aiming
			manager.toggleSights()
			aimingSights = true
			aimSensitivity = 0.6 #calculated from the player's ADS ratio of 15/25
	
	
	#INDEX 8,9,10,11 for WASD
	if(body.moveEnabled):
		if(desiredActions[8] > 0.5):
			body.goFor = true
		if(desiredActions[9] > 0.5):
			body.goLef = true
		if(desiredActions[10] > 0.5):
			body.goRit = true
		if(desiredActions[11] > 0.5):
			body.goBak = true
	#12/13 for crouch/jump (not implemented)
	#14,13,16 for modal

@onready var visionR: Area3D = $"../sylph head v2/senses/vision/triangleR"
@onready var visionL: Area3D = $"../sylph head v2/senses/vision/triangleL"
@onready var visionU: Area3D = $"../sylph head v2/senses/vision/triangleU"
@onready var visionD: Area3D = $"../sylph head v2/senses/vision/triangleD"
var targetsPresent = 1 #assume there's a target.

#gathers sensory info and updates the sensoryInput array
func do_Senses():
	

	#INDEX 0,1,2,3 AND 4,5 + 18: VISION SENSES
	do_Vision()
	#keep in mind 4-5 work are trained on both sylph and target having same root.
	#if this doesnt happen things will be BAD (90% sure this is no longer true with all the changes)

	#INDEX 6: AIM AZIMUTH
	#between 90 and -90
	var head = $"../sylph head v2"
	sensoryInput[6] = (body.sylphHead.rotation_degrees.x / 180) + 0.5 #range of 0-1, let's see if this fixes anything
	
	#INDEX 7: AMMO LEFT
	sensoryInput[7] = manager.get_Ammo_Left()
	
	#INDEX 8: CROSSHAIR SIZE
	sensoryInput[8] = manager.get_Crosshair_Inaccuracy()
	#if(sensoryInput[8] >= -0.74):
		#print("Crosshair size:", sensoryInput[8])

	#INDEX 9: AIMSPEED
	var speed = aimVector.length()
	#equal to the hypotenuse of a iscoceles right triangle (with friction applied)
	var highestPossibleSpeed = sqrt(4 * maxSpeed * maxSpeed) * 0.7
	var adjustedSpeed = speed / highestPossibleSpeed
	#print(speed, " ", highestPossibleSpeed)
	sensoryInput[9] = adjustedSpeed
	
	#INDEX 10: TARGETS PRESENT
	#not currently doing anything with this
	sensoryInput[10] = 1#targetsPresent
	
	#INDEX 11: Health!
	sensoryInput[11] = (ourHP.check_HP() / 50) -1
	
	#INDEX 12,13,14,15: MODAL INPUTS
	#sensoryInput[13] = desiredActions[12]
	#sensoryInput[14] = desiredActions[13]
	#sensoryInput[15] = desiredActions[14]
	#sensoryInput[16] = desiredActions[15]

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
		sensoryInput[4] = 1 #max extrema
		sensoryInput[5] = 1 #max distance
		
	else:
		
		# 4 AND 18: DISTANCE AND EXTREMA
		#issue: targetTrue is the staticbody that gets detected, and has a transform of 0.
		#solution: just use globals?
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
			
		#5: DISTANCE
		#Sylph's max vision range is currently 23, so we'll use that as our basis
		#We'll go from -1 to .90 to better differentiate it from max dist
		# therefore, our range will be 1.9 offset by 1
		#connectingvec / 23 is between 0 and 1
		#var dist = (connectingVec.length() / 12.5) -1 #value between 0 and 2
		var dist = (connectingVec.length() /23) # not married to the idea of dist being negative
		sensoryInput[5] = dist
		
		#INDEX 4: EXTREMA
			
		#Novel idea: Instead of trying to use trig, what if wejust calculate the distance
		#between a point extended (distance) out from the sylph's head, and rotated wherever they're facing?
		var sylphVisCenter: Vector2 
		sylphVisCenter = Vector2(connectingVec.length(), 0)
		sylphVisCenter = sylphVisCenter.rotated(body.sylphHead.rotation.y)
		sylphVisCenter += Vector2(bodpos.x, bodpos.z)
		
		var diff = sylphVisCenter - Vector2(tarpos.x, tarpos.z)
		var offset = diff.length() #tentative max for offset is 12.3
		
		offset /= 6.15
		offset -=1
		sensoryInput[4] = offset
		
		
		#var theta : float 
		#if(absf(connectingVec.x) > absf(connectingVec.z)):
			#theta = atan(connectingVec.z/connectingVec.x)
		#else:
			#theta = atan(connectingVec.x/connectingVec.z)
		#
		#if(theta > 1.5706): #in this case we're rotated 90 degrees
			#theta -= 1.5706
		#elif(theta < -1.5706):
			#theta += 1.5706
		##Theta will be 0 if the sylph
		#
		##sylph bodies never actually rotate, even in motion. only use head rotation.
		#var rotation = 0 - (body.sylphHead.rotation.y) 
		#
		##Sylphs can rotate greater than 360 degrees, and since godot is weird, this doesnt loop around 
		##Since Arctan only outputs between +- 90, we need to calibrate for that range
		#if(rotation > 1.5706):
			#while(rotation > 1.5706):
				#rotation -= 1.5706
		#if(rotation < -1.5706):
			#while(rotation < -1.5706):
				#rotation += 1.5706
		#
		#var change = theta - rotation
		#
		#if(change > 0.48 || change < -0.48):
			#print("Something's seriously up with the extrema! Did you rotate the bodies when you werent meant to?")
		#
		#change = absf(change) #we only care about the absolute.
		#change *= 2.2 #Sylphs only have about 50 degrees of FOV, so our range of values is +- 0.47
		#sensoryInput[4] = clampf(change, 0, 1) #shouldnt ever matter but be safe
		



#returns the target, if any exist in a visionblock, or false.
func get_Vision_Targets(visionBlock:Area3D):
	if(visionBlock.has_overlapping_bodies()):
		var items = visionBlock.get_overlapping_bodies()
		var x:int = 0
		while(x < items.size()):
			if(items[x].is_in_group("sylph_target")):
				if(items[x] == body.ourTar.ourTrueTarget):
					return items[x]
			x+=1
	return null #you have got to be FUCKING kiddin gme
