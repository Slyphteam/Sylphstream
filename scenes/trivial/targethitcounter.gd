class_name SCOREDTARGET extends Node3D
var totalHits:int = 0
var startPos

func _ready():
	startPos = global_position.z

func reset():
	totalHits = 0
	global_position.z = startPos
