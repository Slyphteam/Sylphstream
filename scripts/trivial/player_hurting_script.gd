##Simple script that harms the player by shooting them when a button is pressed.
extends StaticBody3D
@export var damAmount: int = 1

##Creates a bullet that shoots the player.
func interact_By_Player(player):
	var space:PhysicsDirectSpaceState3D = get_world_3d().direct_space_state 
	var end = player.global_position
	var orig = end + Vector3(0, 10, 0) #from DA SKY!
	var theShot = FIREDBULLET.new()
	theShot.assign_Info(orig, end, space, null, damAmount)
	theShot.take_Shot()
