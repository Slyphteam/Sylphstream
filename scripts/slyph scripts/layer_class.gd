##A layer of a neural network. Based in part on Sebastian Lague's open source neural network code
class_name LAYER extends Node

var nodesIn: int
var nodesOut: int
var weights ##Weights for incoming connections; 2D; nodesIn arrays of size nodesOut
#another way to think about weights is the following:
#for each node in the current layer, what modifiers do we have for all incoming nodes?
var biases: Array[float] ##for outgoings


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

#runtime seems to be associated with inputs being an empty array.
#how does this happen?
func calc_Outputs(inputs: Array[float])-> Array[float]:
	if(!inputs):
		print("NO INPUT DATA!! UH OH!!!!!")
	
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
		computedInputs[curOut] = apply_Activation_Threshhold(weightedIn) #apply_Activation_Threshhold(weightedIn)
		curOut+=1
	return computedInputs

func apply_Activation_Threshhold(incoming:float)->float:
	if(incoming > 0.1 && incoming < -0.1):
		return 0
	elif(incoming > 0.7):
		return 1
	elif(incoming < -0.7):
		return -1
	else:
		return incoming

func add_Node_To_Layer():
	print("THIS FUNCTION DOESN'T DO ANYTHING!")
	pass
	#add an incoming weights array
	#is that really it?
