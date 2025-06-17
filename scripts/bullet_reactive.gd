##One of two special raycast nodes. READ COMMENTS IN CLASS FILE FOR MORE INFO.
class_name bullet_reactive extends Node3D

func hit_By_Bullet(dam, damtype, dir, origin):
	print("Target hit! ", dam)

#So: How the Heck Frick does Sylphstream handle collisions and also why is my code so bad?
#TL;DR I use groups and not everything extends this class.

#The class you're looking at right now is a componentified script that extends node3d.
#Godot is great with components. I love it. But I'm also in a bit of a corner.
#See, when a raycast takes place, it doesn't always grab the collider. Shooting a target object
# does, but shooting a sylph, for example, will get you the characterbody3d mode. 
#"Good" programming paradigm leaves me with a fairly easy fix:

#	"Just make a bullet reactive component and have everything call
#	 the hit by bullet function local to that exact component :)"

#Issue with this is that things hit by the bullet still have to have a function call in order to
#pass that along to the component, which will have to vary across types. one for charbody3d,
#one for colliders, one for staticobjects, so on and so forth. At which point I'm better off
#not writing that function at all in the first place and just directly implementing a type unsafe
#version of hit_by_bullet.

#This is what I've done.
#In order to make it harder to mess up, I've added a global group for bullet reactive, and a global
#group for interact reactive. I've kept this script since the targets inherit from it and I'll
#want to make more static objects that have different behavior.
