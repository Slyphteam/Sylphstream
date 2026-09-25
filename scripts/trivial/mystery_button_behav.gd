##Simple script that harms the player by shooting them when a button is pressed.
extends StaticBody3D

@onready var ourMode = $"../../.."
#@export var springtail: Node3D
##Creates a bullet that shoots the player.
var count = 0
func interact_By_Player(player):
	if(ourMode.behavior == 46):
		if(Globalscript.prob(50)):
			player.uiInfo.give_Chat_Message("buh buh buh buh buh buh buh buh buh buh buh buh buh buh buh buh buh buh")
		else:
			player.uiInfo.give_Chat_Message("Test message!" + str(count))
			count+=1
	if(ourMode.behavior == 15):
		player.global_position = Vector3(405.708, 2.616, 23.424)
	elif(ourMode.behavior == 16):
		player.global_position = Vector3(0, 10, 0)
	else:
		print("Wow! You just pressed a MYSTERY BUTTON!")
	
	#print("Randf value ", randf_range(0-testy, testy))
	#print("Better randf value ", Globalscript.better_Randf_Simple(1, 2, 1))
	
