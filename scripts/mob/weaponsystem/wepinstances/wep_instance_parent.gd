##Boilerplate class for instantiated weapon scripts
class_name WEPINSTANCE extends Node
var ourDataSheet: WEAP_INFO

##Boilerplate for loading a wepinstance. Needs an info resource, whether it's for the player, and if so, a reticle
func load_Weapon(wepToLoad:WEAP_INFO):
	ourDataSheet = wepToLoad
	return

##Version of _process() for nodes
func manualProcess(manualProcess):
	pass

##Cleans up any nodes created by the wepinstance.
func unload():
	pass

func give_Player_UI(uiInfo):
	pass
