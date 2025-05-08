extends Node
#this is an ENTIRELY NONFUNCTIONAL script that just contains what I have or haven't done yet
# DIRECTORY OF WHERE SHIT IS:
# playertry2 is the ACTUAL implemented code that does things
# playerinput, playershared, and player_phys are all (mostly) copypasted from
# the godot3 and godot4 sourcelike projects people have worked on

#--KNOWN PROBLEMS:
# mouse wiggling gives a CRAZY boost to speed when moving
# the dynamic headbobbing just adds jitteriness!
# or is there just a lot of jitteriness?
#------if players have a lot of forward velocity, they can't strafe!
# this wasn't a problem before commit b6f117a, before which checkvelocityandmove was called 
# twice (once during phys process and once during the accelerate functions)
# It's a lot less prevalent now though

#NEEDS DOING (in presumed order of precedence):
# change the speed multipliers to one variable that is incremented/decremented based on player state
#Add different accelerations based on player state?
#KICKING!!!
#crouch sliding
#fix viewbob and add camera tilt
#weapons
#turret AI

#FIXED PROBLEMS:
# friction now actually functions in a meaningful way
#    Player seems to fall through the world if they're going too fast?
#    vector3 float runtimes will just happen due to playerVelocity(fixed?)
#    player CAN just look directly down and then phase through the ground through sheer force of will
#    players can fly by holding space

#DONE:
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
