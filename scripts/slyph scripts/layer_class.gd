class_name LAYER extends Node
##based in part on Sebastian Lague's open source neural network code
var nodesIn: int
var nodesOut: int
var weights ##Weights for incoming connections; 2D; INCOMING arrays of size OUTGOING
#another way to think about weights is the following:
#for each node in the current layer, what modifiers do we have for each node in the next layer?
var biases: Array[float] ##Chance to activate each node in the next layer


func initialize_Layer(incoming, outgoing):
	nodesIn = incoming
	nodesOut = outgoing
	weights = create_Empty_Grid(nodesIn, nodesOut)
	biases.resize(outgoing)
	biases.fill(0.5)

func create_Empty_Grid(width, height):
	var grid = []
	for i in width:
		grid.append([])
		for j in height:
			grid[i].append(0.5) # Set a starter value for each position
	return grid

func calc_Outputs(inputs: Array[float])-> Array[float]:
	var computedInputs : Array[float]
	computedInputs.resize(nodesOut)
	
	var curOut:int = 0
	var currentArray
	
	while(curOut < nodesOut):
		var weightedIn = biases[curOut]
		var curIn = 0
		while(curIn < nodesIn):
			currentArray = weights[curIn]
			weightedIn+= inputs[curIn] * currentArray[curOut]
			curIn+=1
		computedInputs[curOut] = weightedIn
		curOut+=1
	return computedInputs

func add_Node_To_Layer():
	print("THIS FUNCTION DOESN'T DO ANYTHING!")
	pass
	#for each array in weights, add a new slot.
	#for the next layer:
	#add a new bias?
	#add a new subarray in weights
