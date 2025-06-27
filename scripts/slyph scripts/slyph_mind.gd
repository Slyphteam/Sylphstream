extends Node

@onready var body = $".."

var aimSensitivity:float = 1 ##fractional multiplier
var ourNetwork:NNETWORK
var mindEnabled = false
var actionsEnabled = false

#func _process(_delta):
	#if(mindEnabled):
		#sensoryInput = do_Vision()
		#if(actionsEnabled):
			#process_Actions(ourNetwork.calc_Outputs(sensoryInput))

func init_Neurons():
	ourNetwork = NNETWORK.new()
	#2 inputs: target in left and target in right
	#3 nodes in the hidden layer because idk
	#3 nodes in the output layer: move left, move right, shoot
	ourNetwork.initialize_Network([3,3,2])
	ourNetwork.populate_Network_Rand()
	print("Sylph neural network sucessfully instantiated!")

func save_To_File(fileString):
	ourNetwork.save_Network_To_File(fileString)

func single_Thought_Test():
	#sensory input, for now, is 3 values:
	#target to left, target to right,and a random noise value.
	sensoryInput = do_Vision()
	sensoryInput.append(randf_range(-1, 1))
	if(!sensoryInput):
		print("we CAN'T SEE!")
	var desiredActions = ourNetwork.calc_Outputs_Network(sensoryInput)
	process_Actions(desiredActions)
	
var sensoryInput:Array
var desiredActions:Array


func process_Actions(desiredActions:Array[float]):
	#for the current test, 1 is left/right, 2 is shoot
	#print("Desired actions:", desiredActions)
	var leftRight = desiredActions[0] * 3 * aimSensitivity #max per-frame movement is 3 degrees
	
	if(leftRight > -0.1 && leftRight < 0.2): #ignore obnoxiously small inputs
		leftRight = 0
	body.move_Head_Exact([0,leftRight])
	
	var shootOrNah = desiredActions[1]
	
	if(shootOrNah > 0.5):
		body.shoot_Wep()
	
	
	pass


@onready var visionR: Area3D = $"../sylph head v2/triangleR"
@onready var visionL: Area3D = $"../sylph head v2/triangleL"
func do_Vision()->Array[float]:
	#var vision:Array[float] = [0,0]
	#vision[0] = do_Eye_See(visionR)
	#[do_Eye_See(visionR), do_Eye_See(visionL)]
	return [do_Eye_See(visionR), do_Eye_See(visionL)]

##Tests to see if there's a target in the eye FOV. Returns 0 or 1 FOR NOW.
func do_Eye_See(eye:Area3D)->float:
	if(eye.has_overlapping_bodies()):
		var items: Array = eye.get_overlapping_bodies()
		var x:int = 0
		while(x < items.size()):
			if(items[x] is testing_target): #only targets for now
				return 1 
			x+=1
	return 0


	
func mutation_Test(val:float):
	
	print("Before mutation:")
	print(ourNetwork.get_Layer(1).weights[0])
	print(ourNetwork.get_Layer(1).weights[1])
	print(ourNetwork.get_Layer(1).weights[2])
	
	ourNetwork.mutate_Network(10)
	#UHOH!!!! DIDNT DO THEM ALL!!!
	print("After mutation:")
	print(ourNetwork.get_Layer(1).weights[0])
	print(ourNetwork.get_Layer(1).weights[1])
	print(ourNetwork.get_Layer(1).weights[2])
