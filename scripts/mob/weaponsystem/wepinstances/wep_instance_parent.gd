##Boilerplate class for instantiated weapon scripts
class_name WEPINSTANCE extends Node
var ourDataSheet: WEAP_INFO 
var weaponMesh: MeshInstance3D
var invManager: INVENMANAGER ##Assigned by the actual manager prior to weapon resource loading
var uiInfo = null ##Single node containing references for all the player's UI stuff, for ease of updating
var affectUI = false ##Should only be true for the player's current weapon instance

##Boilerplate for loading a wepinstance. Needs an info resource, whether it's for the player, and if so, a reticle
func load_Weapon(wepToLoad:WEAP_INFO):
	ourDataSheet = wepToLoad
	return

##Version of _process() for nodes
func manualProcess(_delta):
	pass

##Frees all nodes created by the wepinstance.
func unload():
	pass

func give_Player_UI(newUiInfo):
	
	affectUI = true
	uiInfo = newUiInfo
	return
