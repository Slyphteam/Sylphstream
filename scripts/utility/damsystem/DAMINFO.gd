##Wrapper class for an instance of damage. Largely used to keep things tidy, contains damage int, type (unused), originator, and direction (normalized vector3)
class_name DAMINFO extends Node
var damage: int ##How much damage is being dealt
var damType: int ##Currently entirely unused
var entity:Object ##The dealer of the damage, if such a thing exists
var direction:Vector3 ##The direction of the damage; should be normalized

func assign_Info(dam, typ, ent, dir):
	damage = dam
	damType = typ
	entity = ent
	direction = dir
