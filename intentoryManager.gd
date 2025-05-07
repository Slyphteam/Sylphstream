extends "res://playertry2.gd"
# this is the inventory management script for the player. 
#health, ammunition, item switching, and so on and so forth should go here. 
#Ideally, weapons should be in a seperate script that's extended from this.
var ammo_9mm = 20
enum Ammotypes {blankammo, ninemm}
var ourInven = []

@onready var heldObject = $weapon_parent

#func _ready():
	#ourInven.append( weapon_parent.new() )



#class heldItem:
	#var wepName # = "imcoder!"
	#var selection #= 1
	#var chambering #= Ammotypes.blankammo
