class_name NNETWORK extends Node
var ourLayers: Array[LAYER]

func initializeNetwork(layerSizes: Array[int]):
	var numLayers = layerSizes.size()
	ourLayers.resize(numLayers)
	var i = 0
	while(i<(numLayers-1)):
		ourLayers[i] = LAYER.new()
		ourLayers[i].initialize_Layer(layerSizes[i], layerSizes[i+1])
		i+=1
		
func calcOutputs(inputData:Array[float])->Array[float]:
	var x = 0
	var curLayer: LAYER
	while(x< (ourLayers.size()-1)):
		print("now iterating on ", inputData)
		curLayer = ourLayers[x]
		inputData = curLayer.calc_Outputs(inputData)
		x+=1
	return inputData
