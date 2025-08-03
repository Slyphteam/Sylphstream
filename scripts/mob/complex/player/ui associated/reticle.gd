#Always always, no matter what, draw a dot in the center of the screen. *always.*
extends CenterContainer
func _draw():
	draw_circle(Vector2(0,0), 2, Color.BLACK)
	draw_circle(Vector2(0,0), 1, Color.WHITE)
