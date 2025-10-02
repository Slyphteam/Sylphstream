class_name FIREDBULLET extends Node

var orig: Vector3
var end: Vector3
var spaceState:PhysicsDirectSpaceState3D
var theUser ##reference to the entity who shot the bullet, if applicable
var dam : int

func assign_Info(origIC: Vector3, endIC: Vector3, spaceStateIC:PhysicsDirectSpaceState3D, theUserIC, damIC):
	orig = origIC
	end = endIC
	spaceState = spaceStateIC
	theUser = theUserIC
	dam = damIC
	
func take_Shot():
	var raycheck:PhysicsRayQueryParameters3D
	
	#3 is 110etc, aka the bullet collision layer
	#also, always exclude the weapon's origin/user from getting hit
	if(theUser):
		raycheck = PhysicsRayQueryParameters3D.create(orig, end, 3, [theUser]) 
	else:
		raycheck = PhysicsRayQueryParameters3D.create(orig, end, 3)
	raycheck.collide_with_bodies = true
	var castResult = spaceState.intersect_ray(raycheck)
	
	if(castResult):
		var hitObject = castResult.get("collider")
		if(hitObject.is_in_group("damage_interactible")):
			hitObject.hit_By_Bullet(dam,"UNUSED","UNUSED",theUser)
		if(!hitObject.is_in_group("hit_decal_blacklist")):
			do_Hit_Decal(castResult.get("position"))

func do_Hit_Decal(pos):
	#USE NORMALS!!!!!
	var tree = Globalscript.thePlayer.get_tree()
	var hitdecalscene = preload("res://scenes/trivial/bullet_decal.tscn")
	var decalInstance = hitdecalscene.instantiate()
	tree.root.add_child(decalInstance)
	decalInstance.global_position = pos
	
	#Make our rotation the exact angle of the cast
	#var castVec = orig - pos
	if(theUser):
		if(theUser.is_in_group("has_manager")):
			decalInstance.rotation = theUser.get_invenm().get_Rotation()
			
	
	#otherwise dont bother. arctangents are my bane.
	
	#since there's no longer an invemnanger handler (when was that a good idea?)
	#decalInstance.rotation.x = #acos(castVec.y / castVec.length())
	#var daAngle = atan(castVec.z / castVec.x) #arctangents once again being my bane 
	#ecalInstance.rotation.y = daAngle
	
	#give it some variation on the roll, though
	decalInstance.rotation.z = randi_range(-2, 2)
	
	await tree.create_timer(10).timeout
	decalInstance.queue_free()
