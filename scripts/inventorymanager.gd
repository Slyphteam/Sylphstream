extends Node
var weapParent = load("res://scripts/weapon_parent.gd")
	
enum Ammotypes {ammoBlank, ammoPistol, ammoRifle}
var heldAmmunition = {} # dictionary of all the player's held ammotypes and ammo
	
var heldItem 
var modelreference
@onready var reloadtimer = $Timer

func getAmmoAmt(type):
	return heldAmmunition.type
	
func _init():#wepRef):
	heldAmmunition.ammoBlank = 100
	heldAmmunition.ammoPistol = 24
	#modelreference = wepRef
	heldItem = weapParent.new(Ammotypes, self)
	
	#inventory manager function that tells the held item to attempt shooting
func doShoot():
	heldItem.tryShoot()
	
	#inventory manager function that tells the held item to attempt reloading
func doReload():
	
	reloadtimer.start()
	
	heldItem.startReload()




func _on_timer_timeout() -> void:
	
	print("time!");
	pass # Replace with function body.
