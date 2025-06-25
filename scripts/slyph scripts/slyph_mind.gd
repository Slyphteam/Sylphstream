extends Node

@onready var body = $".."
@onready var visionR: Area3D = $"../sylph head v2/triangleR"
@onready var visionL: Area3D = $"../sylph head v2/triangleL"


func do_Target_Test():
	if(visionR.has_overlapping_bodies()):
		
		var items: Array = visionR.get_overlapping_bodies()
		var x:int = 0
		while(x < items.size()):
			if(items[x] is testing_target):
				print("found something!")
				print(items[x])
			
			x+=1
