extends Node3D

@export var WEP_TYPE: Wep
@onready var weapon_mesh: MeshInstance3D = %DebugWeaponMesh
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_weapon()

func load_weapon():
	weapon_mesh.mesh = WEP_TYPE.mesh
	position = WEP_TYPE.position
	rotation_degrees = WEP_TYPE.rotation
	scale = WEP_TYPE.scale
	#for i in scale:
		#i*= WEP_TYPE.scalar
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
