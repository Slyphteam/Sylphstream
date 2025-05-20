#this is the script that manages the aiming reticle
extends CenterContainer

var dot_rad: float = 2
var dot_col: Color = Color.BLACK
var centerdot_rad: float = 1.0
var centerdot_col: Color = Color.WHITE

#dynamic reticle
@export var crosshairs : Array[Line2D]
@export var ourplayer : CharacterBody3D
@export var reticlespeed : float = 0.25
@export var reticledistance : float = 2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	queue_redraw()

#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _draw():
	draw_circle(Vector2(0,0), dot_rad, dot_col)
	draw_circle(Vector2(0,0), centerdot_rad, centerdot_col)

#for movement speed: lerp crosshairs[0].position, [0,0] + vector 2 of 0, -playerspeed  * reticledistance
#adjust the spread of the crosshairs by a given amount. input MUST be an integer.
func adjust_spread(amount):
	
	crosshairs[0].position = Vector2(0, -amount) 
	crosshairs[1].position = Vector2(0, amount)
	crosshairs[2].position = Vector2(-amount, 0)
	crosshairs[3].position = Vector2(amount, 0)
	pass
