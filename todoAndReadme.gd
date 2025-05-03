extends Node
#this is an ENTIRELY NONFUNCTIONAL script that just contains what I have or haven't done yet
# DIRECTORY OF WHERE SHIT IS:
# playertry2 is the ACTUAL implemented code that does things
# playerinput, playershared, and player_phys are all (mostly) copypasted from
# the godot3 and godot4 sourcelike projects people have worked on

#--KNOWN PROBLEMS:
#if players have a lot of forward velocity, they can't strafe!
# jumping is HORRIBLY broken. 
#how is jumping broken?
#-- Players can jump midair, which behaves as expected
#-- players can jump while moving, behaves as expected
#-- but if players jump from STANDING, they'll float.
#-- If players jump while on the ground, they'll get a TON added to their velocity
#but they won't actually move.
#-- players holding space will jump heigher instead of a fixed amount

#NEEDS DOING (in presumed  order of precedence):
#scenery
#sprinting
#crouching
#fine-tuning to make it feel like gmod

#FIXED PROBLEMS:
#    Player seems to fall through the world if they're going too fast?
#    vector3 float runtimes will just happen due to playerVelocity(fixed?)
#    player CAN just look directly down and then phase through the ground through sheer force of will

#SORT OF DONE:
#sort out sourelike midair
#-- IMPORTANT SUBTASK: go over move_and_slide_sourcelike and jumping code with a fine tooth come
#-- hopefully this should solve our "falling through world" issues.
#figure out and get rid of whatever's causing the jitteriness (fixed?)

#PROBABLY DONE:
#get rid of jitteriness
#mouse integration
