class_name NNETWORK extends Node
var ourLayers: Array[LAYER]

##Create an empty neural network with layer sizes specified in array
func initialize_Network(layerSizes: Array[int]):
	var numLayers = layerSizes.size()
	ourLayers.resize(numLayers)
	var i = 0
	while(i<(numLayers-1)):
		ourLayers[i] = LAYER.new()
		ourLayers[i].initialize_Layer(layerSizes[i], layerSizes[i+1])
		i+=1

##run inputs through the neural network
func calc_Outputs_Network(inputData:Array[float])->Array[float]:
	var x = 0
	var curLayer: LAYER
	while(x< (ourLayers.size()-1)):
		#print("now iterating on ", inputData)
		curLayer = ourLayers[x]
		inputData = curLayer.calc_Outputs(inputData)
		x+=1
	return inputData



###Below are all LAYER functions


##Access a desired layer. Keep in mind that the last "layer" isn't actually simulated as an object
func get_Layer(desiredLayer: int)->LAYER:
	var selectedLay = ourLayers[desiredLayer]
	if(!selectedLay):
		print("UH OH! couldn't access layer!")
	return selectedLay

##Populates a layer with random values between -1 and 1. WILL DESTROY PRE-EXISTING VALUES
func populate_Layer_Rand(desiredLayer: int):
	var selectedLay = get_Layer(desiredLayer)
	
	#biases
	var x:int = 0
	var numBiases = selectedLay.biases.size()
	while (x<numBiases):
		selectedLay.biases[x] = randf_range(-1, 1)
		x+=1
	
	#weights
	x = 0
	var y:int
	var curArray = []
	while(x<selectedLay.nodesOut):
		y=0
		while(y<selectedLay.nodesIn):
			curArray = selectedLay.weights[y]
			curArray[x] = randf_range(-1, 1)
			y+=1
		x+=1

##Mutates a selected layer of by random values clamped by 0+-(mutationAmount)
func mutate_Layer(desiredLayer: int, mutationAmount: float):
	var selectedLay = ourLayers[desiredLayer]
	var newVal:float
	
	#biases
	var x:int = 0
	var numBiases = selectedLay.biases.size()
	while (x<numBiases):
		newVal = clampf(selectedLay.biases[x] + randf_range(0-mutationAmount, mutationAmount), -1, 1)
		selectedLay.biases[x] = newVal
		x+=1
	
	#weights
	x = 0
	var y:int
	var curArray = []
	while(x<selectedLay.nodesOut):
		y=0
		while(y<selectedLay.nodesIn):
			curArray = selectedLay.weights[y]
			curArray[x]
			newVal = clampf(curArray[x] + randf_range(0-mutationAmount, mutationAmount), -1, 1)
			curArray[x] = newVal
			y+=1
		x+=1

##Populates a layer with Weights: a 2d array of size (incoming, outgoing), and Biases: an array of size outgoing
func populate_Layer_Custom(layer: int, biases: Array[float], weights: Array):
	var selectedLay = ourLayers[layer]
	selectedLay.biases = biases
	selectedLay.weights = weights

func copy_Layer_From_Other(otherlayer:LAYER):
	
	pass


#below are all network functions
##Populates a network with random values. WILL OVERWRITE VALUES
func populate_Network_Rand():
	var z:int =0
	
	while(z<ourLayers.size() - 1):
		populate_Layer_Rand(z)
		z+=1
	
	
##Mutates the entire network by random values clamped to 0+-(mutationAmount)
func mutate_Network(mutateBy: float):
	var z:int =0
	
	while(z<ourLayers.size() - 1):
		mutate_Layer(z, mutateBy)
		z+=1

#func copy_values_from_network(otherGuy:NNETWORK):
	#pass

#func load_network_from_file

##Saves network to file. See function comments for more details.
func save_Network_To_File(fileString):
	var ourFile: FileAccess = FileAccess.open(fileString, FileAccess.WRITE)
	
	var z:int = 0
	var x:int = 0
	var constructedString:String
	var currentLayer: LAYER
	var currentArray
	while(z<ourLayers.size() - 1):
		constructedString = "-----LAYER " + str(z) + "----- \n"
		ourFile.store_string(constructedString) #store headers
		
		currentLayer = get_Layer(z)
		constructedString = str(currentLayer.biases) + "\n"
		ourFile.store_string(constructedString) #store layer biases
		
		constructedString = "--WEIGHTS-- \n"
		ourFile.store_string(constructedString)
		x = 0
		while(x < currentLayer.nodesIn):
			currentArray = currentLayer.weights[x]
			constructedString = str(currentArray) + "\n"
			constructedString
			ourFile.store_string(constructedString)
			x+=1
		
		
		z+=1
	
	ourFile.close()
