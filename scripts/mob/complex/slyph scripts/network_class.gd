##A class representing a neural network made from arrays. Includes several utilities.
class_name NNETWORK extends Node

var ourLayers: Array[LAYER]
var layerSizes:String

##Create an empty neural network with layer sizes specified in array
func initialize_Network(layerSizeArr: Array[int]):
	layerSizes = str(layerSizeArr)
	
	var numLayers = layerSizeArr.size()
	ourLayers.resize(numLayers)
	var i = 0
	while(i<(numLayers-1)):
		ourLayers[i] = LAYER.new()
		ourLayers[i].initialize_Layer(layerSizeArr[i], layerSizeArr[i+1])
		i+=1
	
	#ourLayers[0].activations.fill(1) #ensure the first layer always activates.

##run inputs through the neural network
func calc_Outputs_Network(inputData:Array[float])->Array[float]:
	var x = 0
	var curLayer: LAYER
	while(x< (ourLayers.size()-1)):
		#print("now iterating on ", inputData)
		curLayer = ourLayers[x]
		inputData = curLayer.calc_Outputs(inputData)
		x+=1
	
	#for y in inputData:
		#clampf(inputData[y], -1,1)
	
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
	
	##activations
	#x=0
	#while (x<numBiases):
		#selectedLay.activations[x] = randf_range(0.85, 1)
		#x+=1
	
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
	
	

##Mutates a selected layer of by random values clamped by 0+-(mutationAmount). Seperate value for activations.
func mutate_Layer(desiredLayer: int, mutationAmount: float, _activationMut:float, mutationChance: int):
	var selectedLay = ourLayers[desiredLayer]
	var newVal:float
	
	#biases
	var x:int = 0
	var numBiases = selectedLay.biases.size()
	while (x<numBiases):
		if(prob(mutationChance)):
			newVal = clampf(selectedLay.biases[x] + randf_range(0-mutationAmount, mutationAmount), -1, 1)
			selectedLay.biases[x] = newVal
		x+=1
	
	##activations
	#x=0
	#while (x<numBiases): #same number of activations as biases
		#if(prob(mutationChance)):
			#newVal = clampf(selectedLay.activations[x] + randf_range(0-activationMut, activationMut), -1, 1)
			#selectedLay.activations[x] = newVal
		#x+=1
	
	#weights
	x = 0
	var y:int
	var curArray = []
	while(x<selectedLay.nodesOut):
		y=0
		while(y<selectedLay.nodesIn):
			curArray = selectedLay.weights[y]
			#curArray[x]#why was this here?
			if(prob(mutationChance)):
				newVal = clampf(curArray[x] + randf_range(0-mutationAmount, mutationAmount), -1, 1)
				curArray[x] = newVal
			y+=1
		x+=1

##Populates a layer with Weights: a 2d array of size (incoming, outgoing), and Biases: an array of size outgoing
func populate_Layer_Custom(layer: int, biases: Array[float], weights: Array):
	var selectedLay = ourLayers[layer]
	selectedLay.biases = biases
	selectedLay.weights = weights

##Copies layer from another layer. BOTH HAVE TO BE THE SAME DIMENSIONS
func copy_Layer_From_Other(ourLayer:LAYER, theirLayer:LAYER):
	#I coouuuuuld do size sanitity checks. buut nahhhhhhhhhh
	
	#biases
	ourLayer.biases = theirLayer.biases.duplicate(true)

	#weights
	var x:int = 0
	while(x<theirLayer.nodesIn): #ordinarily y is used for nodesIn but there is only one loop here
		ourLayer.weights[x] = theirLayer.weights[x].duplicate(true) #if this doesnt work im gonna cry
		x+=1

#below are all network functions
##Populates a network with random values. WILL OVERWRITE VALUES
func populate_Network_Rand():
	var z:int =0
	
	while(z<ourLayers.size() - 1):
		populate_Layer_Rand(z)
		z+=1
	
	#ourLayers[0].activations.fill(1) #ensure the first layer always activates.
	

#experimental function that mutates in "pulses" through a network.
#selects a random node, mutates it, selects a random node from the outgoing, mutates
#func mutate_Pulse(mutateBy, mutateChance, pulseChance, maxPulse):
	#return
	#
#
#func get_Pulse_Neurons()->Array:
	#


##Mutates the entire network by random values clamped to 0+-(mutationAmount). Seperate value for mutations.
func mutate_Network(mutateBy: float, activationMut: float, mutationChance: int):
	var z:int =0
	
	while(z<ourLayers.size() - 1):
		mutate_Layer(z, mutateBy, activationMut, mutationChance)
		z+=1
	
	#ourLayers[0].activations.fill(1) #ensure the first layer always activates.

#func do_SGD_Learning()
#How does SGD learning work?
#from https://youtu.be/hfMk-kjRv4c&t=1236
#In an "instant" neural network, like one that recognizes images, its the following:
#goes through all weights, makes a tiny nudge, then measures the cost and logs it in the network's gradient list
#divide change in cost by the nudge to measure sensitivity
#does the same for biases. Afterwards, apply the gradients onto all the layers.
#This works great if you can instantly get the "cost" of a neural network, but if I had to 
#go through every single parameter in my networks and individually trial them, it'd take literal 
#hours to make a single "step" in SGD.
#Clearly a no-go, but there's gotta be a better way than random evolution.
#Ideas:
#Look up that guy who did the learning cube videos in unity(?) and see what he did
#Scale up the number of sylphs. More "evolutions" per generation = better improvement
#Think about a way to "record" the random mutation and then re-apply it (or re-apply something like it)
#the reasoning being that, if one mutation makes a sylph improve slightly, that same mutation will
#yield slightly more fitness again, so on and so forth until a different mutation produces a greater yield.

#func copy_values_from_network(otherGuy:NNETWORK):
	#pass

func load_Network_From_File(fileString):
	var ourFile: FileAccess = FileAccess.open(fileString, FileAccess.READ)
	var lineGrabber : String =  ourFile.get_line()
	var currentArray : Array
	var currentLayer: LAYER
	
	if(lineGrabber != layerSizes): #check and ensure both networks are the same "size"
		print("Load failed! Networks are different sizes!")
		ourFile.close()
		return
	

	var z:int = 0
	var x:int = 0
	
	
	while(z< ourLayers.size() - 1): #per layer
		currentLayer = get_Layer(z)
		
		lineGrabber = ourFile.get_line() #layer header
		lineGrabber = ourFile.get_line() #biases header
		lineGrabber = ourFile.get_line() #biases
		currentArray = str_to_var(lineGrabber)
		currentLayer.biases = currentArray.duplicate()
		
		lineGrabber = ourFile.get_line() #activations header
		lineGrabber = ourFile.get_line() #activations
		#currentArray = str_to_var(lineGrabber)
		#currentLayer.activations = currentArray.duplicate()
		
		lineGrabber = ourFile.get_line() #weights header
		
		
		
		x = 0
		while(x < currentLayer.nodesIn): #process the weights
			lineGrabber = ourFile.get_line()
			currentArray = str_to_var(lineGrabber)
			currentLayer.weights[x] = currentArray.duplicate()
			
			x+=1
		z+=1
	
	ourFile.close()

##Saves network to file. See function comments for more details.
func save_Network_To_File(fileString):
	var ourFile: FileAccess = FileAccess.open(fileString, FileAccess.WRITE)
	
	var z:int = 0
	var x:int = 0
	var constructedString:String
	var currentLayer: LAYER
	var currentArray
	
	constructedString = layerSizes + "\n"
	ourFile.store_string(constructedString) #store nodal data
		
	while(z<ourLayers.size() - 1):
		
		
		constructedString = "-----LAYER " + str(z) + "----- \n"
		ourFile.store_string(constructedString) #store headers
		
		currentLayer = get_Layer(z)
		constructedString = "--BIASES-- \n"
		ourFile.store_string(constructedString)
		constructedString = var_to_str(currentLayer.biases) + "\n"
		ourFile.store_string(constructedString) #store layer biases
		
		constructedString = "--ACTIVATION CHANCES-- \n"
		ourFile.store_string(constructedString)
		constructedString = "(we arent doing those) \n"
		ourFile.store_string(constructedString)
		
		constructedString = "--WEIGHTS-- \n"
		ourFile.store_string(constructedString)

		x = 0
		while(x < currentLayer.nodesIn):
			currentArray = currentLayer.weights[x]
			constructedString = var_to_str(currentArray) + "\n"
			ourFile.store_string(constructedString)
			x+=1
		
		
		z+=1
	
	ourFile.close()

func copy_From_Other(other:NNETWORK):
	
	var z:int =0
	var thisLay: LAYER
	var theirLay: LAYER
	
	while(z<ourLayers.size() - 1):
		thisLay = get_Layer(z)
		theirLay = other.get_Layer(z)
		copy_Layer_From_Other(thisLay, theirLay)
		z+=1

func prob(chance:int)->bool:
	var targ = randi_range(0, 100)
	if(chance >= targ):
		return true
	
	return false
