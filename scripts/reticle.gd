#this is the script that manages the aiming reticle
extends CenterContainer

var dot_rad: float = 2
var dot_col: Color = Color.BLACK
var centerdot_rad: float = 1.0
var centerdot_col: Color = Color.WHITE

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
	
