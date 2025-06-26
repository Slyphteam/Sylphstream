class_name LAYER  extends Node
##based in part on Sebastian Lague's open source neural network code
var nodesIn: int
var nodesOut: int
var weights ##weights for incoming connections, 2d
var biases: Array[float] ##biases for each node in the layer

func initialize_Layer(incoming, outgoing):
	nodesIn = incoming
	nodesOut = outgoing
	weights = create_Empty_Grid(nodesIn, nodesOut)
	biases.resize(outgoing)

func create_Empty_Grid(width, height):
	var grid = []
	for i in width:
		grid.append([])
		for j in height:
			grid[i].append(i+j) # Set a starter value for each position
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
