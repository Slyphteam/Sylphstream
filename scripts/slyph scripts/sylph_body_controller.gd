extends CharacterBody3D
@onready var sylphHead = $"sylph head v2"
@onready var collider = $sylphcollider
@onready var mind = $"slyph mind"
@onready var manager : INVENMANAGER = $"sylph head v2/sylphinventory"


func hit_By_Bullet(_dam, _damtype, _dir, _origin):
	#print("ow!")
	move_Head_Exact(Vector2(10,0))

func interact_By_Player(playerRef)->bool:
	
	var networkTest = NNETWORK.new()
	networkTest.initializeNetwork([2,3,2])
	var outs = networkTest.calcOutputs([1.1,2.2])
	print("outs",outs)
	

	#neural layer test
	#var layertest = LAYER.new()
	#layertest.initialize_Layer(3, 2) #3 in, 
	#var inputArray: Array[float] = [1.1,2.2,3.3]
	#var outs = layertest.calc_Outputs(inputArray)
	#print(outs)
	
	#var orig = manager.get_Origin()
	#manager.get_End(orig, 0, 0)
	#manager.doShoot()
	
	
	#self.global_position = Vector3(0, 0, 0)

	#mind.do_Target_Test()
	
	
	return false



func move_Head(desired: Vector2):
	#TODO: in the future add inaccuracy with higher speeds
	move_Head_Exact(desired)

##Moves the Sylph's head with a vector containing the degrees of lift/drift desired. X will rotate "down" and Y will rotate "left"
func move_Head_Exact(desired: Vector2):
	var lift = desired.x #not necessary to do this, but for legibility I am anyway
	var drift = desired.y
	sylphHead.rotation_degrees.x += lift
	sylphHead.rotation_degrees.y += drift
	var newangle = sylphHead.rotation_degrees.y
	
	var diff = newangle - collider.rotation_degrees.y
	if(abs(diff) > 40):
		collider.rotation_degrees.y = (newangle + collider.rotation_degrees.y) / 2
