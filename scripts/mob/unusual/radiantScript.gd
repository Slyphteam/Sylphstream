extends Node3D
@onready var lay1 = $layer1
@onready var lay2 = $layer2
@onready var lay3 = $layer3
@onready var lay4 = $layer4
@onready var lay5 = $layer5
@onready var lay6 = $layer6

var twopi = 2 * PI

func _process(delta: float) -> void:
	lay1.rotation.y += 0.003
	lay2.rotation.y -= 0.003
	lay3.rotation.y += 0.005
	lay4.rotation.y -= 0.005 
	lay5.rotation.y += 0.008 
	lay6.rotation.y -= 0.008
	
	if(lay1.rotation.y > twopi):
		lay1.rotation.y = 0
		lay2.rotation.y =0
	
	if(lay3.rotation.y > twopi):
		lay3.rotation.y	= 0
		lay4.rotation.y	= 0
	
	if(lay5.rotation.y > twopi):
		lay5.rotation.y = 0
		lay6.rotation.y = 0
