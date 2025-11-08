##Simple script that harms the player by shooting them when a button is pressed.
extends StaticBody3D
@export var pressLength:float = 0.1 #should be float with delta coverage but ehhhhhhhhhhh
@onready var ourTimer = $"../Timer"
var isPressed: bool = false



##Creates a bullet that shoots the player.
func interact_By_Player(player):
	doPress()

	
func doPress():
	isPressed = true #yeah sure you can repress a button if you want.
	ourTimer.start()
	await ourTimer.timeout
	isPressed = false
