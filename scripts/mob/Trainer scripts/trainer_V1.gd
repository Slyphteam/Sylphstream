class_name trainerV1 extends TRAINER

var testTime:int = 0
var testing = false
var folderDirectory: String = "res://Saved AI Agents/Sylphs/Targs1/"

func _process(delta):
	
	if(testing):
		if(testTime > 0):
			testTime -=1
			if(testTime <=1):
				if(testing):
					restart_Sylph_Test()
			if(testTime == 50): #we've waited 450 frames, score it now
				score_Sylphs_All()
				

##Starts or stops a round of testing
func toggle_Test():
	
	if(testing):
		testing = false
	else:
		print("Starting test!")
		begin_Sylph_Test()
		testing = true 

##Initializes two random Sylphs and starts testing them
func begin_Sylph_Test():
	print("Starting test!")
	allScores.resize(Globalscript.activeSylphs.size())
	#for curSylph in Globalscript.activeSylphs:
		#used to be randomize here as an option but that was added to the body behavior for now
		#curSylph.load_From_File(folderDirectory+"highscore.txt")
	restart_Sylph_Test()

##Does a new cycle of testing
func restart_Sylph_Test():
	
	testTime = 750
	for curSylph in Globalscript.activeSylphs:
		curSylph.begin_Test()


var allScores: Array
var hitMult: int = 3 ##Multiplicative reward for hits
var missDiv: int =  0 ##Divide penalty for misses by this amount
var missAllow: int = 1000000 ##How many misses will we tolerate before punishing?
var accuracyRew: int = 0 ##If we're in the tolerance, what reward is given?
var visionDiv: int = 350 ##What will we divide the per-frame penalty by for not seeing target?

var prevBest = -80
var revertcount = 0
var mutAmount = 0.09
var mutPercent = 1

var generation: int = 1
var highScore = -12

##Function that scores all sylphs in the global allSylphs array
func score_Sylphs_All():
	var ind = 0
	for curSylph in Globalscript.activeSylphs:
		allScores[ind] = curSylph.score_Performance(hitMult, missDiv, missAllow, accuracyRew, visionDiv)
		ind+=1
	
	var bestScore = -150
	var bestScoreInd 
	var secondBestScore = -200
	var secondScoreInd 
	#var thirdBestScore = -300
	#var thirdBestInd
	
	var highScoreInd = -1
	
	ind = 0
	
	for curScore in allScores:
		if(curScore[1] > bestScore):
			bestScore = curScore[1]
			bestScoreInd = ind
		elif(curScore[1] > secondBestScore):
			secondBestScore = curScore[1]
			secondScoreInd = ind
		#elif(curScore[0] > thirdBestScore):
			#thirdBestScore = curScore[0]
			#thirdBestInd = ind
		ind +=1
	
	
	
	print(allScores)
	print("Best score: ", bestScore, " [", bestScoreInd, "] Runner-up ", secondBestScore, " [", secondScoreInd, "]")
	
	ind = 0
	#if(bestScore < (prevBest - 1)):
		#print("reverting. count: ", revertcount)
		##for curSylph in Globalscript.activeSylphs:
			##curSylph.load_From_File("res://resources/txt files/sylph tests/generations test 2/highscore.txt")
			##if(ind > 2):
				##curSylph.ourNetwork.mutate_Network(mutAmount, 0, 50) 
			##ind +=1
		#revertcount +=1
		#
		#if(revertcount > 7):
			#print("too much revertion!")
		#
		#prevBest -= 2
		#return
	#else:
		#revertcount = 0
		#
		#if(bestScore >prevBest):
			#prevBest = bestScore
	
	
	if(bestScore >= highScore):
		print("Highscore beat!")
		highScore = bestScore
		highScoreInd = bestScoreInd
		
		Globalscript.activeSylphs[highScoreInd].save_To_File(folderDirectory+"highscore.txt")
	
	Globalscript.activeSylphs[bestScoreInd].save_To_File(folderDirectory+"currentBest.txt")
	Globalscript.activeSylphs[secondScoreInd].save_To_File(folderDirectory+"currentSecond.txt")
	
	
	

	generation +=1
	
	if(generation > 120):
		print("thats enough!")
	
	print("Generation: ", generation)
	#if(generation == 120):
		#Globalscript.activeSylphs[bestScoreInd].save_To_File(folderDirectory+"gen120.txt")
	#
	ind = 0
	for curSylph in Globalscript.activeSylphs:
		
		if(ind != bestScoreInd && ind != secondScoreInd):
			if(Globalscript.prob(60)):
				#print("  Copied from best!")
				curSylph.copy_From_Other(Globalscript.activeSylphs[bestScoreInd])
			else:
				#print("  Copied from second!")
				curSylph.copy_From_Other(Globalscript.activeSylphs[secondScoreInd])
		
		ind+=1
	
	ind = 0
	for curSylph in Globalscript.activeSylphs:
		if(ind != bestScoreInd):
			if(Globalscript.prob(50)): #coin flip to mutate
				if(Globalscript.prob(50)):
					curSylph.ourNetwork.mutate_Network(0.15, 0, 30) #dont mutate best, second, or highscore
				else: #allow for some whacky mutations to happen, keep the gene pool fresh
					if(Globalscript.prob(50)):
						curSylph.ourNetwork.mutate_Network(0.3, 0, 1)
					else:
						curSylph.ourNetwork.mutate_Network(0.05, 0, 50)
					print("  Mutated!")
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
	#var keptScore = 0
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
