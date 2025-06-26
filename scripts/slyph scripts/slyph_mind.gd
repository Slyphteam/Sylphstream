extends Node

@onready var body = $".."
@onready var visionR: Area3D = $"../sylph head v2/triangleR"
@onready var visionL: Area3D = $"../sylph head v2/triangleL"

var mindEnabled = false

func _process(delta):
	pass
	#if(mindEnabled):
		

func do_Target_Test():
	if(visionR.has_overlapping_bodies()):
		
		var items: Array = visionR.get_overlapping_bodies()
		var x:int = 0
		while(x < items.size()):
			if(items[x] is testing_target):
				print("found something!")
				print(items[x])
			
			x+=1

func do_Neural_Test():
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
