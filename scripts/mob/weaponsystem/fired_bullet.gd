class_name FIREDBULLET extends Node

var orig: Vector3
var end: Vector3
var spaceState:PhysicsDirectSpaceState3D
var invManager
var dam : int

func assign_Info(origIC: Vector3, endIC: Vector3, spaceStateIC:PhysicsDirectSpaceState3D, manager, damIC):
	orig = origIC
	end = endIC
	spaceState = spaceStateIC
	invManager = manager
	dam = damIC
	
func take_Shot():
	var raycheck:PhysicsRayQueryParameters3D
	
	#3 is 110etc, aka the bullet collision layer
	#also, always exclude the weapon's origin/user from getting hit
	raycheck = PhysicsRayQueryParameters3D.create(orig, end, 3, [invManager.user]) 
	raycheck.collide_with_bodies = true
	var castResult = spaceState.intersect_ray(raycheck)
	
	if(castResult):
		var hitObject = castResult.get("collider")
		if(hitObject.is_in_group("damage_interactible")):
			hitObject.hit_By_Bullet(dam,2,3,4)
		if(!hitObject.is_in_group("hit_decal_blacklist")):
			do_Hit_Decal(castResult.get("position"))

func do_Hit_Decal(pos):
	var managerTree = invManager.get_tree()
	var hitdecalscene = preload("res://scenes/trivial/bullet_decal.tscn")
	var decalInstance = hitdecalscene.instantiate()
	managerTree.root.add_child(decalInstance)
	decalInstance.global_position = pos
	decalInstance.rotation = invManager.get_Rotation()
	
	decalInstance.rotation.z = randi_range(-2, 2)
	await managerTree.create_timer(10).timeout
	decalInstance.queue_free()
