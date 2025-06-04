extends Node
#this is an ENTIRELY NONFUNCTIONAL script

# DIRECTORY OF WHERE SHIT IS:

# the MOST important scripts are as follow:
# --scripts/player/held_weapon_behavior: acts as a data instance for the held weapon
# -- scripts/player/invenManager (NOT invnetorymanager): Tracking ammunition and communicating 
#    with the player/held item
# --scripts/player/playermovementinput: Kinematic controller for the player, input/output

# Other places are as follow:
# resources/weaponresources contains all the templates for implemented weapons
# Models/glbs and textures for the raws of all imported models
# Scenes/player associated/player for the actual player scene
# Scenes/environ for the test environment I have the player in

#--KNOWN PROBLEMS:
#-- it's REALLY hard to jump up on a platform (is it?)
#--players can't "step" up a ledge, no matter how small


#NEEDS DOING (in presumed order of precedence):
#get better pistol gunshot
#footstep sounds
#change invenmanager to be the child of a custom class so we can have differing method calls
#ADS makes the camesa zoom in
#inaccuracy with the dynamic recoil system
#crosshair changes with speed
#context-sensitive leaning
#ammo pickups
#weapon switching
#fix weapon clipping (but do i really care that much ?)

#KICKING!!!
#fix viewbob 
# add camera tilt
#weapons
#turret AI

#FIXED PROBLEMS:
# friction now actually functions in a meaningful way
#    Player seems to fall through the world if they're going too fast?
#    vector3 float runtimes will just happen due to playerVelocity(fixed?)
#    player CAN just look directly down and then phase through the ground through sheer force of will
#    players can fly by holding space
# crouching causes a weird and mostly harmless runtime

#DONE:
#modular weapon system
#sprinting
#scenery
#sort out sourelike midair
#-- IMPORTANT SUBTASK: go over move_and_slide_sourcelike and jumping code with a fine tooth comb
#-- hopefully this should solve our "falling through world" issues.
#figure out and get rid of whatever's causing the jitteriness (fixed?)

#PROBABLY DONE:
#crouching
#get rid of jitteriness
#mouse integration
