extends Node3D


var freq = 2
var danceAmplitude = 4
var calcdSin : float
var testTime:int = 0
var testing = false


func look_At_Player(player:Node3D):
		#use trig to calculate the angle our archon should rotate to
	#in order to face the player
	var locationalVec: Vector2 = Vector2(player.position.x - self.position.x, 
										 player.position.z - self.position.z)
	
	#prior to this, it's coordinates, which don't sit on a circle
	locationalVec = locationalVec.normalized() 
	var hypotenuse = locationalVec.length()
	
	#getting the logic to work here took WAY longer than I'd have liked tbh >:(
	var angle: float = 0
	if (locationalVec.x < 0):
		angle = asin(locationalVec.y / hypotenuse)
		self.rotation.y =  angle + deg_to_rad(-90)
	else:
		angle = acos(locationalVec.y / hypotenuse)
		self.rotation.y =  angle



func get_Talked_To(player:Node3D):
	#print("Hi Millian! What can I do for you today?")
	look_At_Player(player)
	if(testing):
		testing = false
	else:
		begin_Sylph_Test()
		testing = true 
	

func do_Archon_Gaylittlefloat(delta):
	calcdSin = sin(Globalscript.timer * freq)
	var tilt = calcdSin * danceAmplitude
	self.rotation.z = deg_to_rad(tilt)

func _process(delta):
	do_Archon_Gaylittlefloat(delta)
	if(testTime > 0):
		testTime -=1
		if(testTime <=1):
			if(testing):
				restart_Sylph_Test()
		if(testTime == 50): #we've waited 450 frames, score it now
			score_Sylphs_All()
		


##Initializes two random Sylphs and starts testing them
func begin_Sylph_Test():
	print("Starting test!")
	allScores.resize(Globalscript.allSylphs.size())
	for curSylph in Globalscript.allSylphs:
		curSylph.load_From_File("res://resources/txt files/sylph tests/generations test 2/highscore.txt")
	restart_Sylph_Test()

##Does a new cycle of testing
func restart_Sylph_Test():
	
	testTime = 450
	for curSylph in Globalscript.allSylphs:
		curSylph.begin_Test()


var allScores: Array


var hitMult: int = 7 ##Multiplicative reward for hits
var missDiv: int =  10 ##Divide penalty for misses by this amount
var missAllow: int = 10 ##How many misses will we tolerate before punishing?
var accuracyRew: int = 0 ##If we're in the tolerance, what reward is given?
var visionDiv: int = 50 ##What will we divide the per-frame penalty by for not seeing target?

var prevBest = -30
var revertcount = 0
var mutAmount = 0.09
var mutPercent = 1

var generation: int = 50
var highScore = -30

##Function that scores all sylphs in the global allSylphs array
func score_Sylphs_All():
	var ind = 0
	for curSylph in Globalscript.allSylphs:
		allScores[ind] = curSylph.score_Performance(hitMult, missDiv, missAllow, accuracyRew, visionDiv)
		ind+=1
	
	var bestScore = -100
	var bestScoreInd 
	var secondBestScore = -200
	var secondScoreInd 
	var thirdBestScore = -300
	var thirdBestInd
	
	var newHigh
	var highScoreInd = -1
	
	ind = 0
	
	for curScore in allScores:
		if(curScore[1] > bestScore):
			bestScore = curScore[1]
			bestScoreInd = ind
		elif(curScore[1] > secondBestScore):
			secondBestScore = curScore[1]
			secondScoreInd = ind
		elif(curScore[1] > thirdBestScore):
			thirdBestScore = curScore[1]
			thirdBestInd = ind
		ind +=1
	
	
	
	print(allScores)
	print("Best score: ", bestScore, " ", bestScoreInd, " Runner-up ", secondBestScore, " ", secondScoreInd)
	
	ind = 0
	if(bestScore < (prevBest - 3)):
		print("reverting. count: ", revertcount)
		for curSylph in Globalscript.allSylphs:
			curSylph.load_From_File("res://resources/txt files/sylph tests/generations test 2/highscore.txt")
			if(ind > 2):
				curSylph.ourNetwork.mutate_Network(mutAmount, 0, 50) 
			ind +=1
		revertcount +=1
		
		if(revertcount > 20):
			print("too much revertion!")
		
		prevBest -= 1
		return
	else:
		revertcount = 0
		
		if(bestScore >prevBest):
			prevBest = bestScore
	
	
	if(bestScore > highScore):
		print("Highscore beat!")
		highScore = bestScore
		highScoreInd = bestScoreInd
		Globalscript.allSylphs[highScoreInd].save_To_File("res://resources/txt files/sylph tests/generations test 2/highscore.txt")
	
	Globalscript.allSylphs[bestScoreInd].save_To_File("res://resources/txt files/sylph tests/generations test 2/currentBest.txt")
	Globalscript.allSylphs[secondScoreInd].save_To_File("res://resources/txt files/sylph tests/generations test 2/currentSecond.txt")
	
	
	

	generation +=1
	
	if(generation > 100):
		print("thats enough!")
	
	print("Generation: ", generation)

	if(generation == 60):
		Globalscript.allSylphs[bestScoreInd].save_To_File("res://resources/txt files/sylph tests/generations test 2/gen60.txt")
	elif(generation == 70):
		Globalscript.allSylphs[bestScoreInd].save_To_File("res://resources/txt files/sylph tests/generations test 2/gen70.txt")
	elif(generation == 80):
		Globalscript.allSylphs[bestScoreInd].save_To_File("res://resources/txt files/sylph tests/generations test 2/gen800.txt")
	elif(generation == 90):
		Globalscript.allSylphs[bestScoreInd].save_To_File("res://resources/txt files/sylph tests/generations test 2/gen90.txt")
	elif(generation == 100):
		Globalscript.allSylphs[bestScoreInd].save_To_File("res://resources/txt files/sylph tests/generations test 2/gen100.txt")

	
	ind = 0
	for curSylph in Globalscript.allSylphs:
		
		if(ind != bestScoreInd && ind != secondScoreInd):
			if(Globalscript.prob(60)):
				#print("  Copied from best!")
				curSylph.copy_From_Other(Globalscript.allSylphs[bestScoreInd])
			else:
				#print("  Copied from second!")
				curSylph.copy_From_Other(Globalscript.allSylphs[secondScoreInd])
		
		ind+=1
	
	ind = 0
	for curSylph in Globalscript.allSylphs:
		if(ind != bestScoreInd):
			if(Globalscript.prob(80)):
				curSylph.ourNetwork.mutate_Network(0.01, 0, 5) #dont mutate best, second, or highscore
			else:
				if(Globalscript.prob(50)):
					curSylph.ourNetwork.mutate_Network(0.3, 0, 1)
				else:
					curSylph.ourNetwork.mutate_Network(0.01, 0, 40)
			#print("  Mutated!")
		#else:
			#print("  Didn't!")
		ind +=1
	


@export var Sylph1:CharacterBody3D
@export var Sylph2:CharacterBody3D
@export var targ1 : SCOREDTARGET
@export var targ2 : SCOREDTARGET


#start with vision training, then penalize misses

var totalSum: int = -3
var tolerance = 2

##Function that scores two sylphs from export vars
func score_Sylphs_Two():
	
	#vision, miss +4 vs -2
	#score with
	var arr1 = Sylph1.mind.score_Performance(targ1, hitMult, missDiv, missAllow, accuracyRew, visionDiv)
	var arr2 = Sylph2.mind.score_Performance(targ2, hitMult, missDiv, missAllow, accuracyRew, visionDiv)
	
	print(arr1)
	print(arr2)
	
	#update our generations. 
	generation+=1
	var keptScore = 0
	var avgScore = float(totalSum) / float(generation)
	print("Test complete! new average ", avgScore, " Generation: ", generation)
	
	if(arr1[1] < avgScore && arr2[1] < avgScore):
		if(highScore > 1):
			generation-=1
			print("Both sucked!") #only load 1 sylph for sake of testing
			Sylph1.mind.load_From_File()
			
	elif(arr1[1] > arr2[1]):
		print("Sylph1 was better!")
		totalSum += arr2[1]
		
		if(arr1[1] > highScore):
			print("new best!")
			highScore = arr1[1]
			Sylph1.mind.save_To_File("res://resources/txt files/sylph tests/gradient descent tests/progtry1.txt")
		
		if(arr1[1] > avgScore - tolerance):
			Sylph1.mind.save_To_File("res://resources/txt files/sylph tests/gradient descent tests/progtry1.txt")  #only save if we're doing "good"
		
		Sylph2.mind.copy_From_Other(Sylph2)
		Sylph1.mind.ourNetwork.mutate_Network(0.1, 0, 40)
		
		
	elif(arr1[1] < arr2[1]):
		print("Sylph2 was better!")
		totalSum +=  arr2[1]
		
		if(arr2[1] > highScore):
			print("new best!")
			highScore = arr2[1]
			Sylph2.mind.save_To_File("res://resources/txt files/sylph tests/gradient descent tests/progtry1.txt")
		
		if(arr2[1] > avgScore - tolerance): 
			Sylph2.mind.save_To_File("res://resources/txt files/sylph tests/gradient descent tests/progtry1.txt")
	
		Sylph1.mind.copy_From_Other(Sylph2)
		Sylph1.mind.ourNetwork.mutate_Network(0.1, 0, 40)



	else:
		print("both tied!") #go again!
		if(highScore < -2):
			Sylph1.mind.initialize_Rand_Network()
			Sylph2.mind.initialize_Rand_Network()
		else:
			Sylph1.mind.ourNetwork.mutate_Network(0.3, 0, 1)
			generation -=1 # dont update average, so decrement generations again
	
	if(generation > 25 || arr2[0] >= 5 || arr1[0] >= 5):
		Sylph1.mind.save_To_File("res://resources/txt files/sylph tests/gradient descent tests/progtry1.txt")
		print("probably enough now!")
