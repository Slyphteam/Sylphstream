extends Node
@onready var ourSylph = $"../sylph body"
@onready var butF = $"../Button F/buttongreen/StaticBody3D"
@onready var butR = $"../Button R/buttongreen/StaticBody3D"
@onready var butL = $"../Button L/buttongreen/StaticBody3D"

func _process(delta):
	if(butF.isPressed):
		ourSylph.goFor = true
	if(butR.isPressed):
		ourSylph.goLef = true
	if(butL.isPressed):
		ourSylph.goRit = true
