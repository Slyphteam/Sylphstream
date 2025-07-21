class_name SCOREDTARGET extends Node3D
var totalHits:int = 0
var startPos: Vector3 

func _ready():
	startPos = global_position
	var move:float = randi_range(-20, 20) #frick floats, do integer steppings
	move /= 20
	global_position.z = clamp(startPos.z - 3, global_position.z + move, startPos.z + 3 )

func reset():
	totalHits = 0
	global_position = startPos
	global_position.z += randf_range(-0.5, 0.5)
	#global_position.x += randf_range(-0.5, 0.5) #forwards back
