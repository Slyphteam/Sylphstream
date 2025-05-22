extends Node
#this is an ENTIRELY NONFUNCTIONAL script

# DIRECTORY OF WHERE SHIT IS:

# the MOST important scripts are as follow:
# --held_weapon_behavior: acts as a data instance for the held weapon
# -- invnManager (NOT invnetorymanager): Tracking ammunition and communicating 
#    with the player/held item
# --playermovementinput: Kinematic controller for the player, input/output

# Other places are as follow:
# scripts/weaponresources contains all the templates for implemented weapons
# Models-> glbs and textures for the raws of all imported models
# Scenes -> player associated -> player for the actual player scene
# Scenes -> environ for the test environment I have the player in


#--KNOWN PROBLEMS:
# it's REALLY hard to jump up on a platform (is it?)
#players can't "step" up a ledge, no matter how small
# mouse wiggling gives a CRAZY boost to speed when moving
#------if players have a lot of forward velocity, they can't strafe!
# this wasn't a problem before commit b6f117a, but is a lot better?

#NEEDS DOING (in presumed order of precedence):
#ADS before ANY new firearms
#player hud! it's been long enough!
#recoil moves camera!
#speed-based dynamic crosshair with the minimum
#make reload time actually dependent on weapon info!

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
