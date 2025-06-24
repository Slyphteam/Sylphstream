class_name ARCHONHELPER extends Node3D

func _process(delta):
	do_Archon_Gaylittlefloat(delta)
	

var bobAmplitude = 200
var freq = 2
var danceAmplitude = 4
var calcdSin : float

func do_Archon_Gaylittlefloat(delta):
	calcdSin = sin(Globalscript.timer * freq)
	#print(calcdSin)
	#self.position.y += cos(Globalscript.timer) / bobAmplitude #don't like this
	
	var tilt = calcdSin * danceAmplitude
	self.rotation.z = deg_to_rad(tilt)

func get_Talked_To(player:Node3D):
	print("Hi Millian! What can I do for you today?")
	look_At_Player(player)
	file_Load_Test()
	

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
	
	var ourFile: FileAccess = FileAccess.open("res://resources/txt files/examplefile.txt", FileAccess.WRITE)
	var line1 : String = ourFile.get_line()
	print(line1)
	#var line2 : String = ourFile.get_line()
	#print(line2)
	#var line3 : String =
	#var line4 : String =
	ourFile.close()
	
