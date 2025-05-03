extends Node
#this is an ENTIRELY NONFUNCTIONAL script that just contains what I have or haven't done yet
# DIRECTORY OF WHERE SHIT IS:
# playertry2 is the ACTUAL implemented code that does things
# playerinput, playershared, and player_phys are all (mostly) copypasted from
# the godot3 and godot4 sourcelike projects people have worked on

#--KNOWN PROBLEMS:
#if players have a lot of forward velocity, they can't strafe!


#NEEDS DOING (in presumed  order of precedence):
#fix how EASY bunnyhopping is
#sprinting
#crouching
#fine-tuning to make it feel like gmod
# double check handleSourcelikeAir

#FIXED PROBLEMS:
#    Player seems to fall through the world if they're going too fast?
#    vector3 float runtimes will just happen due to playerVelocity(fixed?)
#    player CAN just look directly down and then phase through the ground through sheer force of will
#    players can fly by holding space

#DONE:
#scenery
#sort out sourelike midair
#-- IMPORTANT SUBTASK: go over move_and_slide_sourcelike and jumping code with a fine tooth come
#-- hopefully this should solve our "falling through world" issues.
#figure out and get rid of whatever's causing the jitteriness (fixed?)

#PROBABLY DONE:
#get rid of jitteriness
#mouse integration
