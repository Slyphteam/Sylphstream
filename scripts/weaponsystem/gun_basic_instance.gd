##The corresponding weapon script class for the FIREARM_INFO data resource
class_name GUNBASICINSTANCE extends WEPINSTANCE

var weaponMesh: MeshInstance3D
var ourReticle: CenterContainer 
var gunshotPlayer: AudioStreamPlayer3D 
var reloadPlayer: AudioStreamPlayer3D



func load_Weapon(wepToLoad:WEAP_INFO, isPlayer: bool, reticle: CenterContainer ):
	print("Loadin a weap!")
	#Instantiate other components we'll need to function
	weaponMesh = MeshInstance3D.new()
	if(isPlayer):
		ourReticle = reticle
	gunshotPlayer = AudioStreamPlayer3D.new()
	reloadPlayer = AudioStreamPlayer3D.new()

func manualProcess():
	pass
