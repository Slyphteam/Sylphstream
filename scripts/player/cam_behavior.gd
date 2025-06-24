## PLAYER CAMERA
# Manages bobbing, tilt, minor camera adjustments
extends Camera3D

# external variables
@export var bob_speed_target : float = 0.0
@export var tilt_amount_target : float = 0.0
@export var bob_intensity : float = 3.0
@export var lerp_val : float = 0.1

@export var player : CharacterBody3D

# internal variables
var bob_time : float = 0.0
var bob_speed : float = 0.0
var tilt_amount : float = 0.0 # negative is to the left, positive is to the right

func _process(delta):
	handleBob(delta)
	handleTilt()#delta)

func handleBob(delta):
	# set values based on player stats
	bob_speed_target = max(player.playerSpeed / 2.0, 1.0)
	bob_intensity = max(player.playerSpeed / 500.0, 0.01)
	
	bob_speed = lerp(bob_speed, bob_speed_target, lerp_val)
	bob_time += delta * bob_speed
	#bob_time = Globalscript.timer * bob_speed
	var bob_offset = bob_intensity * sin(bob_time)
	position.y = bob_offset

#delta was unused so I commented it out
func handleTilt(): #delta):
	# set values based on player stats
	var sideways_vel = player.playerVelocity.dot(player.playerCam.basis.x)  # get sideways velocity
	
	# normal sideways movement
	tilt_amount_target = sideways_vel / 5.0
	
	# croushsliding override
	if player.crouchSliding:
		if abs(sideways_vel) < 10.0:
			tilt_amount_target = 10.0
		else:
			tilt_amount_target = sideways_vel / 2.0
	
	tilt_amount = lerp(tilt_amount, tilt_amount_target, lerp_val)
	
	rotation.z = - tilt_amount / 100.0 # tweak these values to your hearts content
