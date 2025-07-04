##Boilerplate class for instantiated weapon scripts
class_name WEPINSTANCE extends Node

##Boilerplate for loading a wepinstance. Needs an info resource, whether it's for the player, and if so, a reticle
func load_Weapon(wepToLoad:WEAP_INFO, isPlayer: bool, reticle: CenterContainer ):
	pass

##Version of _process() for nodes
func manualProcess():
	pass

##Cleans up any nodes created by the wepinstance.
func unload():
	pass
