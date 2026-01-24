##Simple script that harms the player by shooting them when a button is pressed.
extends StaticBody3D

@onready var ourMode = $"../../.."
#@export var springtail: Node3D
##Creates a bullet that shoots the player.
func interact_By_Player(player):
	if(ourMode.behavior == 15):
		player.global_position = Vector3(405.708, 2.616, 23.424)
	elif(ourMode.behavior == 16):
		player.global_position = Vector3(0, 10, 0)
	else:
		print("Wow! You just pressed a MYSTERY BUTTON!")
	
	#print("Randf value ", randf_range(0-testy, testy))
	#print("Better randf value ", Globalscript.better_Randf_Simple(1, 2, 1))
	
