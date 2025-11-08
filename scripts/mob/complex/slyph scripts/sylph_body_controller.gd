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
	if(moveEnabled):
		calcKinemInput()
		doMove()
var leftright:float
var forback:float
var sylphVel: Vector3 = Vector3.ZERO
var sylphSpeed = 0
func calcKinemInput():
	
	var bonus = 3
	var limit = 13 * 10 #player walkspeed is 13
	
	#sprint/crouch/whatnot logic would go here
	#this might seem cargo cult-y to the player's kinematic controller
	#but truth be told I have no idea how much or how little I want sylphs to be able to do
	#so I'm keeping the patterns the exact same
	
	if(sylphSpeed == 0 && leftright == 0 && forback == 0): 
		bonus = 90
	
	leftright += int(bonus) * (int(goLef )) * Globalscript.deltaButNotStinky
	leftright -= int(bonus) * (int(goRit )) * Globalscript.deltaButNotStinky
	
	forback += int(bonus) * (int(goFor)) * Globalscript.deltaButNotStinky
	forback -= int(bonus) * (int(goBak )) * Globalscript.deltaButNotStinky
	
	#clamp movement, should be the same as how the player does it
	if(!goLef && !goRit):
		if(leftright > 2): #in the player script this set the input to be 0 straight but im predicting sylphs
							# will be a lot less consistent with their movement; so will need soft stops
			leftright /=2
		else:
			leftright = 0
	else:
		leftright = clamp(leftright, (0-limit), limit)
		
	if(!goFor && !goBak):
		if(forback > 2): 
			forback /=2
		else:
			forback = 0
	else:
		forback = clamp(forback, (0-limit), limit)
	
	#reset all of our inputs for next frame
	if(goFor):
		goFor = false
	if(goLef):
		goLef = false
	if(goRit):
		goRit = false
	if(goBak):
		goBak = false

func doMove():
	#might seem silly to have a function that does nothing but call another function
	#but as mentioned earlier, if I go all out, there'd be stuff like air/crouchslide
	#code between domove and dofloormove
	doFloorMove()

func doFloorMove():
	pass
