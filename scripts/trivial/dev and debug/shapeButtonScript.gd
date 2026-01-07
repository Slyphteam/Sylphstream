##script for the shape buttons
extends StaticBody3D
@export var objectType:int = 1
func interact_By_Player(player):
	if(objectType == 3):
		print("Blue sphere")
	if(objectType == 2):
		print("Red cone")
	print("you just pressed the shape button")
