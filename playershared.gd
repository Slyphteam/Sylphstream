#extends CharacterBody3D
## much of this code is interpreted from 
##https://github.com/atlrvrse/GodotSourceEngineMovement
## Vectors
#var vel = Vector3.ZERO
#var snap = Vector3.DOWN
#
## Onready
#@onready var view = $came
##@onready var collidertop = $top
#@onready var colliderbottom = $bottom
##func _ready(): -> void():
##	pass
#
## ConVars
#var ply_mousesensitivity = 2
#var ply_maxlookangle_down = -90
#var ply_maxlookangle_up = 90
#var ply_ylookspeed = 0.3
#var ply_xlookspeed = 0.3
#var ply_sidespeed = 20
#var ply_upspeed = 20
#var ply_forwardspeed = 20
#var ply_backspeed = 20
#var ply_maxspeed = 32
#var ply_accelerate = 20
#var ply_airaccelerate = 20
#var ply_airspeedcap = 15
#var ply_maxacceleration = 1000
#var ply_friction = 4
#var ply_stopspeed = 100
#var ply_gravity = 140
#var ply_maxslopeangle = deg_to_rad(45)
#var ply_maxvelocity = 35000
#var ply_jumpheight = 6
#
#var ply_crouchstanceheight = 3
#var ply_crouchedheight = -1
#var ply_crouchlerpweight = 0.4
#
## Bools
##var noclip : bool
#var crouching : bool
#var crouched : bool
#var sprinting : bool
#
#
## Floats
#var sidemove : float
#var upmove : float
#var forwardmove : float
#var ylook : float
#var xlook : float
#var maxspeed : float
#
#
#func _process(delta: float) -> void:
	#var shittyinput = Input.get_action_strength("ui_up");
	#velocity = shittyinput * Vector3.FORWARD * 1200*delta
