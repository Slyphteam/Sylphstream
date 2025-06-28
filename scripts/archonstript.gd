extends Node3D
@export var Sylph1:CharacterBody3D
@export var Sylph2:CharacterBody3D
@export var targ1 : SCOREDTARGET
@export var targ2 : SCOREDTARGET


var freq = 2
var danceAmplitude = 4
var calcdSin : float
var testTime:int = 0
var testing = false

func get_Talked_To(player:Node3D):
	#print("Hi Millian! What can I do for you today?")
	look_At_Player(player)
	if(testing):
		restart_Sylph_Test()
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
		if(testTime == 1):
			testTime = 0
			score_Sylphs()


##Initializes two random Sylphs and starts testing them
func begin_Sylph_Test():
	
	Sylph1.mind.initialize_Rand_Network()
	Sylph1.mind.load_From_File("res://resources/txt files/very promising sylph.txt")
	Sylph2.mind.initialize_Rand_Network()
	Sylph2.mind.load_From_File("res://resources/txt files/very promising sylph.txt")
	restart_Sylph_Test()

##Does a new cycle of testing
func restart_Sylph_Test():
	print("Beginning new test!")
	Sylph1.mind.begin_Test()
	Sylph2.mind.begin_Test()
	testTime = 410

func score_Sylphs():
	
	Sylph1.mind.body.manager.startReload()
	Sylph2.mind.body.manager.startReload()
	
	var penalty1 = Sylph1.mind.body.manager.penalty
	var penalty2 = Sylph2.mind.body.manager.penalty
	
	print("penalties: ", penalty1, ":", penalty2)
	
	var score1 = targ1.totalHits
	var score2 = targ2.totalHits
	
	#var penalty1 = 

#penalize excessive ammo consumption
	if(penalty1 > 5):
		score1 -=2
	if(penalty2 > 5):
		score2-=2
	if(penalty1> 12):
		score1-=5
	if(penalty2> 12):
		score1-=5
	
	if(score1 >= 12 || score2 >= 12):
		print("NEW RECORD!")
	

	if((score1 <= 3) && (score2 <= 3)): #both were REALLY bad, start from our GOAT
		print("Both sucked!")
		Sylph1.mind.load_From_File("res://resources/txt files/very promising sylph.txt")
		Sylph2.mind.load_From_File("res://resources/txt files/very promising sylph.txt")
	elif(score1 == score2): #mutate them both a sizable amount
		print("Both tied! ", score1, ", ", score2)
		Sylph1.mind.ourNetwork.mutate_Network(0.2)
		Sylph2.mind.ourNetwork.mutate_Network(0.2)

#replace the lower (sylph 2) with a mutated version of the winner
#if the previous loser does better, they'll supercede the old winner, otherwise, the mutation will be discarded
	elif(score1 > score2):
		print("Sylph 1 was better! ", score1, ": ", score2)
		

		Sylph1.mind.save_To_File("res://resources/txt files/promising slyph.txt")
		Sylph2.mind.load_From_File("res://resources/txt files/promising slyph.txt")
		Sylph2.mind.ourNetwork.mutate_Network(0.01)
	else:
		print("Sylph 2 was better! ", score1, ": ", score2)
		
		Sylph2.mind.save_To_File("res://resources/txt files/promising slyph.txt")
		Sylph1.mind.load_From_File("res://resources/txt files/promising slyph.txt")
		Sylph1.mind.ourNetwork.mutate_Network(0.01)
	
	
	targ1.totalHits = 0
	targ2.totalHits = 0

	

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
	
