extends RigidBody3D

var casingMesh:MeshInstance3D
@export var customScale: Vector3
@export var casingType:int = 3
var meshOverride:Mesh

func _ready():
	
	if(casingType != 3):
		casingMesh = MeshInstance3D.new()
	else:
		casingMesh = $"30CalMesh"
