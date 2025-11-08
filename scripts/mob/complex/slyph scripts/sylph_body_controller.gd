extends CharacterBody3D
##Controller code for the Sylph. Relies on sylph_mind for inputs.
@onready var sylphHead = $"sylph head v2"
@onready var collider = $sylphcollider
@onready var mind = $"slyph mind"
@onready var ourHealth = $COMPLEXHEALTHHOLDER
@onready var manager : INVENMANAGER = $"sylph head v2/sylphinventory"
@export var ourTar: Node3D
@export var moveEnabled:bool = false

var shoot = false
func hit_By_Bullet(dam, _damtype, _dir, originator):
	if(originator):
		if(originator == Globalscript.thePlayer):
			print("Ow! You shot me for ", dam, " damage!")
	
	var newHP = ourHealth.take_Dam(dam)
	
	if(newHP <= 0):
		print("OWWW! I just died!")
		
		#will need more work on this in the future
		rotation_degrees.x = 90
	
	

func interact_By_Player(_playerRef):
	
	print("Hi! My current HP is ", ourHealth.health, " with ", ourHealth.aura, " aura")
	#mind.do_Single_Thought(1/60)
	#mind.begin_Test()
	#mind.do_Vision()
	



##Moves the Sylph's head with a vector containing the degrees of rotation in vertical, horizontal
func move_Head_Exact(desired: Vector2):
	sylphHead.rotation_degrees.x -= desired.y #up/down. yeah it's subtractive. welcome to godot.
	sylphHead.rotation_degrees.y += desired.x #side/side
	
	#to past self: you have to use the return value for clamp to work, dummy
	sylphHead.rotation_degrees.x = clampf(sylphHead.rotation_degrees.x, -90, 90) 
	
	#This code would update the body's rotation, which looked cool, but isn't something I want to deal with yet
	#var newangle = sylphHead.rotation_degrees.y
	#
	#var diff = newangle - collider.rotation_degrees.y
	#if(abs(diff) > 40):
		#collider.rotation_degrees.y = (newangle + collider.rotation_degrees.y) / 2

func get_invenm():
	return manager


#########KINEMATIC CODE BELOW

var goFor:bool = false
var goLef:bool = false
var goRit:bool = false
var goBak:bool = false

func _process(delta):
	
	if(goFor):
		goFor = false
	if(goLef):
		goLef = false
	if(goRit):
		goRit = false
	if(goBak):
		goBak = false
