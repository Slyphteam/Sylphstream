##A layer of a neural network. Based in part on Sebastian Lague's open source neural network code
class_name LAYER extends Node

var nodesIn: int
var nodesOut: int ##also the number of nodes in a layer.
var weights ##Weights for incoming connections; 2D; nodesIn arrays of size nodesOut
#another way to think about weights is the following:
#for each node in the current layer, what modifiers do we have for all incoming nodes?
var biases: Array[float] ##The value of each node when it fires

#var gradientWeight
#var gradientBias: Array[float]

var activations: Array[float] ##the chance for each node to fire (disabled)

func initialize_Layer(incoming, outgoing):
	nodesIn = incoming
	nodesOut = outgoing
	weights = create_Empty_Grid(nodesIn, nodesOut)
	#gradientWeight = create_Empty_Grid(nodesIn, nodesOut)
	
	
	biases.resize(outgoing)
	biases.fill(0)
	
	#gradientBias
	
	activations.resize(outgoing)
	activations.fill(1)

func create_Empty_Grid(width, height):
	var grid = []
	for i in width:
		grid.append([])
		for j in height:
			grid[i].append(0) # Set a starter value for each position
	return grid
#
#func apply_Gradients(learnRate):
	#var x:int = 0
	#var numBiases = biases.size()
	#while (x<numBiases):
		#biases[x] -= gradientBias[x] * learnRate
		#x+=1
	##weights
	#x = 0
	#var y:int
	#var curArray = []
	#while(x<nodesOut):
		#y=0
		#while(y<nodesIn):
			#curArray = weights[y]
			#curArray[x] -= gradientWeight[x][y] * learnRate
			#y+=1
		#x+=1


#runtime seems to be associated with inputs being an empty array.
#how does this happen?
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
		computedInputs[curOut] = apply_Activation(weightedIn) #apply_Activation_Threshhold(weightedIn)
		curOut+=1
	return computedInputs


##Given a weighted input and the node's activation chance, see if it fires.
func apply_Activation(incoming:float)->float:
	incoming = clampf(incoming, -1, 1)
	
	if(absf(incoming) < 0.01): #activation threshhold
		incoming = 0
	
	incoming *= 0.7 #TOO MUCH ACTIVATION! turn that shit off!
	
	#if(weighted_Prob(chance)):
	return incoming
	#else:
	#	return 0
	
##given a float from -1 - 0 - 1, makes weighted 1-99% roll for that chance. Somewhat complicated, see code for details.
func weighted_Prob(chance)->bool:
	chance = absf(chance) #Can take negative inputs
	#Rather than going from 0-100% on 0-1, instead fo from 1-99. Therefore, the range is
	#actually 0-98 + 1
	var val = int(chance * 98) + 1
	var targ = randi_range(0, 100)
	if(val >= targ):
		return true
	
	return false

#func add_Node_To_Layer():
	#print("THIS FUNCTION DOESN'T DO ANYTHING!")
	#pass
	#add an incoming weights array
	#is that really it?
