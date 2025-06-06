extends Node3D
##This is a DEPRECATED script that formerly loaded weapon information
@export var WEP_TYPE: Wep
@onready var weapon_mesh: MeshInstance3D = $wepmodel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_weapon()

func load_weapon():
	
	print("hi!!!!!!!!!!!!")
	print("Loading blah blah mesh: ", WEP_TYPE.mesh)
	weapon_mesh.mesh = WEP_TYPE.mesh
	
	position = WEP_TYPE.position
	rotation_degrees = WEP_TYPE.rotation
	scale = WEP_TYPE.scale
	#for i in scale:
		#i*= WEP_TYPE.scalar
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
