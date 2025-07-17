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
		if(testTime == 250): #we've waited 450 frames, score it now
			score_Sylphs()
		


##Initializes two random Sylphs and starts testing them
func begin_Sylph_Test():
	#Sylph1.mind.initialize_Rand_Network()
	#Sylph2.mind.initialize_Rand_Network()
	Sylph1.mind.load_From_File("res://resources/txt files/sylph tests/full sylphs attempt 2/slightly better.txt")
	Sylph2.mind.load_From_File("res://resources/txt files/sylph tests/full sylphs attempt 2/foundations.txt")
	restart_Sylph_Test()

##Does a new cycle of testing

#TODO: WEIGHTED VS UNWEIGHTED SCORES
#for example, weighted score might be 200 because i have a 50x multiplier on targets
#unweighted is just out of 15
func restart_Sylph_Test():
	print("Beginning new test!")

	
	Sylph1.mind.begin_Test()
	Sylph2.mind.begin_Test()
	testTime = 700

#	score_Sylphs()


@export var Sylph1:CharacterBody3D
@export var Sylph2:CharacterBody3D
@export var targ1 : SCOREDTARGET
@export var targ2 : SCOREDTARGET


#start with vision training, then penalize misses
var hitMult: int = 1 ##Multiplicative reward for hits
var missDiv: int =  0 ##Divide penalty for misses by this amount
var missAllow: int = 50 ##How many misses will we tolerate before punishing?
var accuracyRew: int = 0 ##If we're in the tolerance, what reward is given?
var visionDiv: int = 700 ##What will we divide the per-frame penalty by for not seeing target?

var totalSum: int = -3
var generation: int = 0
var tolerance = 2
var highScore = -3

func score_Sylphs():
	
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
			Sylph1.mind.load_From_File("res://resources/txt files/sylph tests/full sylphs attempt 2/primitive.txt")
			
	elif(arr1[1] > arr2[1]):
		print("Sylph1 was better!")
		totalSum += arr2[1]
		
		if(arr1[1] > highScore):
			print("new best!")
			highScore = arr1[1]
			Sylph1.mind.save_To_File("res://resources/txt files/sylph tests/full sylphs attempt 2/primitive.txt")
		
		if(arr1[1] > avgScore - tolerance):
			Sylph1.mind.save_To_File("res://resources/txt files/sylph tests/full sylphs attempt 2/primitive.txt")  #only save if we're doing "good"
		
		Sylph2.mind.copy_From_Other(Sylph2)
		Sylph1.mind.ourNetwork.mutate_Network(0.1, 0, 40)
		
		
	elif(arr1[1] < arr2[1]):
		print("Sylph2 was better!")
		totalSum +=  arr2[1]
		
		if(arr2[1] > highScore):
			print("new best!")
			highScore = arr2[1]
			Sylph2.mind.save_To_File("res://resources/txt files/sylph tests/full sylphs attempt 2/primitive.txt")
		
		if(arr2[1] > avgScore - tolerance): 
			Sylph2.mind.save_To_File("res://resources/txt files/sylph tests/full sylphs attempt 2/primitive.txt")
	
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
		Sylph1.mind.save_To_File("res://resources/txt files/sylph tests/full sylphs attempt 2/current best.txt")
		print("probably enough now!")

#https://docs.godotengine.org/en/stable/classes/class_fileaccess.html#class-fileaccess
#https://docs.godotengine.org/en/stable/tutorials/io/runtime_file_loading_and_saving.html
# https://kidscancode.org/godot_recipes/4.x/basics/file_io/index.html
func file_Load_Test():
	var ourFile: FileAccess = FileAccess.open("res://resources/txt files/examplefile.txt", FileAccess.READ)
	var line1 : String = ourFile.get_line()
	var line2 : String = ourFile.get_line()
	print(line1)
	print(line2)
	ourFile.close()
	




#this code is DEPRECATED!
#func score_Sylphs():
	#Sylph1.mind.body.manager.startReload()
	#Sylph2.mind.body.manager.startReload()
	#
	#var score1 = targ1.totalHits
	#var score2 = targ2.totalHits
	#
	#print("Raw scores: ", score1, " , ", score2)
	#
	##no matter what, if neither get points, it doesnt matter
	#if((score1 == 0) && (score2 == 0)): 
		#print("Both sucked!")
		#Sylph2.mind.save_To_File("res://resources/txt files/backup promising sylph.txt")
		#Sylph1.mind.load_From_File("res://resources/txt files/promising slyph.txt")
	#
	#
	#score1-= int(Sylph1.mind.microPenalty / 10)
	#score2-= int(Sylph2.mind.microPenalty / 10)
	#
	#print("Movement penalties: ", Sylph1.mind.microPenalty/10, " ", Sylph2.mind.microPenalty/10)
	#
	#var penalty1 = Sylph1.mind.body.manager.penalty
	#var penalty2 = Sylph2.mind.body.manager.penalty
	#
	#print("Empty shots: ", penalty1, ":", penalty2)
	#
	#
	##penalize excessive shooting (easy)
	#if(penalty1 < 2 ):
		#score1 +=1
	#else:
		#score1 -= penalty1/2
		#
	#if(penalty2 < 2 ):
		#score2 +=1
	#else:
		#score2 -= penalty2/2
	#
	###penalize excessive shooting
	##if(penalty1 == 0):
		##score1 +=1
	##else:
		##score1 -= penalty1
		##
	##if(penalty2 == 0):
		##score2 +=1
	##else:
		##score2 -= penalty2
	#
	#print("Adjusted scores: ", score1, " , ", score2)
	#
#
#
	#
	#if(score2 >= 14):
		#Sylph2.mind.save_To_File("res://resources/txt files/backup promising sylph.txt")
		#Sylph2.mind.save_To_File("res://resources/txt files/very promising sylph.txt")
		#print("Perfection acheived! ", score1, ": ", score2)
	#elif(score2 >= 10):
		#Sylph2.mind.save_To_File("res://resources/txt files/backup promising sylph.txt")
		#print("Did okay!")
	#
	#if(score1 >= 14):
		#Sylph1.mind.save_To_File("res://resources/txt files/backup promising sylph.txt")
		#Sylph1.mind.save_To_File("res://resources/txt files/very promising sylph.txt")
		#print("Perfection acheived! ", score1, ": ", score2)
	#elif(score1 >= 10):
		#Sylph1.mind.save_To_File("res://resources/txt files/backup promising sylph.txt")
		#print("Did okay!")
#
	#if((score1 <= 2) && (score2 <= -2)): #both were REALLY bad, start from our GOAT
		#print("Both sucked!")
		#Sylph2.mind.save_To_File("res://resources/txt files/backup promising sylph.txt")
		#Sylph1.mind.load_From_File("res://resources/txt files/promising slyph.txt")
		#
	#elif(score1 == score2): #mutate them both a sizable amount
		#print("Both tied! ", score1, ", ", score2)
		#Sylph1.mind.ourNetwork.mutate_Network(0.1, 0)
		#Sylph2.mind.ourNetwork.mutate_Network(0.1, 0)
	#
	##replace the lower (sylph 2) with a mutated version of the winner
	##if the previous loser does better, they'll supercede the old winner, otherwise, the mutation will be discarded
	#elif(score1 > score2):
		#print("Sylph 1 was better! ", score1, ": ", score2)
		#
#
		#Sylph1.mind.save_To_File("res://resources/txt files/promising slyph.txt")
		#Sylph2.mind.load_From_File("res://resources/txt files/promising slyph.txt")
		#Sylph2.mind.ourNetwork.mutate_Network(0.005, 0)
	#else:
		#print("Sylph 2 was better! ", score1, ": ", score2)
		#
		#Sylph2.mind.save_To_File("res://resources/txt files/promising slyph.txt")
		#Sylph1.mind.load_From_File("res://resources/txt files/promising slyph.txt")
		#Sylph1.mind.ourNetwork.mutate_Network(0.005, 0)
	#
	#
	#targ1.totalHits = 0
	#targ2.totalHits = 0
	#Sylph1.mind.microPenalty = 0
	#Sylph2.mind.microPenalty = 0
	
