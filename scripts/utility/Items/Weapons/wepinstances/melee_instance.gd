##Boilerplate class for instantiated weapon scripts
class_name MELEEINSTANCE extends WEPINSTANCE


##Boilerplate for loading a wepinstance. Needs an info resource, whether it's for the player, and if so, a reticle
func load_Weapon(wepToLoad:WEAP_INFO):
	weaponMesh = MeshInstance3D.new()
	invManager.add_child(weaponMesh)
	weaponMesh.mesh = wepToLoad.mesh
	weaponMesh.position = wepToLoad.position
	weaponMesh.rotation_degrees = wepToLoad.rotation
	weaponMesh.scale = wepToLoad.scale

##Version of _process() for nodes
#func manualProcess(manualProcess):
	#pass

##Frees all nodes created by the wepinstance.
func unload():
	weaponMesh.queue_free()

func trySwing():
	print("swing!")

func tryBlock():
	print("parry!")
