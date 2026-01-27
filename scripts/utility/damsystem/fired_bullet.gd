class_name FIREDBULLET extends Node

var orig: Vector3
var end: Vector3
var spaceState:PhysicsDirectSpaceState3D
#var theUser ##reference to the entity who shot the bullet, if applicable
#var dam : int
var ourDamInfo:DAMINFO


func assign_Info(origIC: Vector3, endIC: Vector3, spaceStateIC:PhysicsDirectSpaceState3D, theDamInfo):
	orig = origIC
	end = endIC
	spaceState = spaceStateIC
	#theUser = theUserIC
	#dam = damIC
	ourDamInfo = theDamInfo
	
	
	
func take_Shot():
	var raycheck:PhysicsRayQueryParameters3D
	
	#3 is 110etc, aka the bullet collision layer
	#also, always exclude the weapon's origin/user from getting hit
	if(ourDamInfo.entity):
		raycheck = PhysicsRayQueryParameters3D.create(orig, end, 3, [ourDamInfo.entity]) 
	else:
		raycheck = PhysicsRayQueryParameters3D.create(orig, end, 3)
	raycheck.collide_with_bodies = true
	var castResult = spaceState.intersect_ray(raycheck)
	
	if(castResult):
		
		ourDamInfo.direction = (castResult.get("position") - orig)
		#assign_Info(dam, "UNUSED", theUser, castResult.get("position") - orig)
		
		#print(castResult)
		var hitObject = castResult.get("collider")
		if(!hitObject.is_in_group("hit_decal_blacklist")):
			do_Hit_Decal(ourDamInfo, hitObject, castResult)
		if(hitObject.is_in_group("damage_interactible")):
			hitObject.hit_By_Bullet(ourDamInfo)
		

func do_Hit_Decal(damInfo, item, castResult):
	
	#USE NORMALS!!!!!
	var hitdecalscene = preload("res://scenes/trivial/decals/bullet_decal.tscn")
	var decalInstance = hitdecalscene.instantiate()
	item.add_child(decalInstance)
	
	
	
	#Globalscript.theTree.root.add_child(decalInstance)
	
	decalInstance.scale = Vector3(1.5,1.5,1.5) #reset the scale, prevent jank
	decalInstance.global_rotation = Vector3.ZERO
	
	#yes, these are reversed. Things work right now and i'm terrified to break them.
	
	
	var direction = (orig - castResult.get("position")).normalized() 
	#var direction = damInfo.direction
	
	var hypotenuse = sqrt((direction.x * direction.x) + (direction.z * direction.z))
	
	#Horizontal rotation (bearing)
	var testOne = deg_to_rad(-90)
	
	if(direction.x > 0):
		if(direction.z < 0):
			testOne = acos(direction.z / hypotenuse) + deg_to_rad(90)
		else:
			testOne = acos(direction.z / hypotenuse) + deg_to_rad(90)
			#print ("result ", testOne)
			#testOne = asin(direction.x / hypotenuse) + deg_to_rad(90)
			#print ("result ", testOne)
	else:
		if(direction.z < 0):
			testOne = asin(direction.z / hypotenuse) #this works, DONT TOUCH IT
		else:
			
			testOne = asin(direction.z / hypotenuse) #i have NO IDEA why we use arcsin twice here
			
	#things I learned spending several h ours doing this:
	#acos(a/h) = asin(b/h)
	#there's an inflection point in trig with absolute coordinates, and depending on the
	#trig function used, that inflection point changes
	#you can get around the inflection point by swapping the functions around and offsetting by 90
	#does this mean you can also use the equality I discovered earlier and not swap functions? yea probably..
	#but since i collapsed a dimension and didn't have a B side for the second calculation, it's not guaranteed
	
	#you can simplify things by collapsing one dimension, but watch out!
	#if you're testing with markers and they're curving convex instead of concave, swap the function around
	
#backup:
	#if(direction.x > 0):
		#if(direction.z < 0):
			#testOne = acos(direction.z / hypotenuse) + deg_to_rad(90)
		#else:
			#
			#testOne = asin(direction.x / hypotenuse) + deg_to_rad(90)
	#else:
		#if(direction.z < 0):
			#testOne = asin(direction.z / hypotenuse) #this works, DONT TOUCH IT
		#else:
			#print ("result ", testOne)
			#testOne = asin(direction.z / hypotenuse) #i have NO IDEA why we use arcsin twice here
			#
	
	#Vertical rotation (azimuth)
	var testTwo = deg_to_rad(-45)
	#we're treating the "flat" aspects of dimensions as collapsed for this, x and y are absorbed into absolute length (hypotenuse from earlier)
	var span = hypotenuse 
	hypotenuse = sqrt((direction.y * direction.y) + (direction.z * direction.z))
	#print(direction)
	if(direction.y < 0): #aiming up
		#
		#print(hypotenuse)
		testTwo = acos(span/hypotenuse)
	else: 
		testTwo = asin(span/hypotenuse) - deg_to_rad(90)
	
	decalInstance.global_rotation.y = testOne
	decalInstance.global_rotation.x = 0#randi_range(-2, 2) #this bugged everything >:(
	decalInstance.global_rotation.z = testTwo
	
	#since there's no longer an invemnanger handler (when was that a good idea?)
	#decalInstance.rotation.x = #acos(castVec.y / castVec.x)
	#var daAngle = atan(castVec.z / castVec.x) #arctangents once again being my bane 
	#ecalInstance.rotation.y = daAngle
	
	#give it some variation on the roll, though
	#decalInstance.rotation.z = randi_range(-2, 2)
	
	decalInstance.global_position = castResult.get("position")
	
	
	
	await Globalscript.theTree.create_timer(30).timeout
	if(decalInstance):
		decalInstance.queue_free()
