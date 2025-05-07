extends Node
#this is an ENTIRELY NONFUNCTIONAL script that just contains what I have or haven't done yet
# DIRECTORY OF WHERE SHIT IS:
# playertry2 is the ACTUAL implemented code that does things
# playerinput, playershared, and player_phys are all (mostly) copypasted from
# the godot3 and godot4 sourcelike projects people have worked on

#--KNOWN PROBLEMS:
# the dynamic headbobbing just adds jitteriness.
#------if players have a lot of forward velocity, they can't strafe!
# this wasn't a problem before commit b6f117a, before which checkvelocityandmove was called 
# twice (once during phys process and once during the accelerate functions), but
# that caused a lot of jitteriness and was generally bad code. 
# currently, a player moving forward will curve to the left or right. 
# since they're accelerating in that direction, the left/right movement adds on to the current vector
# Additionally, that "fix" no longer seems to work?
# Additionally additionally, it seems like calling friction before/after accelerate has no bearing
# on fixing this problem. Rather, the player was just faster then.
# unless it was a combination of friction before AND two checks?
# Source doesn't act like this, though. If you've maxxed velocity and you go left as well,
# the left movement and the forward movement combine to be diagonal.
# this works from standing with sylphstream!

# could it be that we just aren't accelerating fast enough? That might explain the large curve
# instead of the intended big one. The end result for the player DOES seem to be diagonal movement.
# in that case, I'd have to crank acceleration and then fine-tune everything from there, which 
# doesn't sound super appealing.

#NEEDS DOING (in presumed  order of precedence):
#crouching

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
#-- IMPORTANT SUBTASK: go over move_and_slide_sourcelike and jumping code with a fine tooth come
#-- hopefully this should solve our "falling through world" issues.
#figure out and get rid of whatever's causing the jitteriness (fixed?)

#PROBABLY DONE:
#get rid of jitteriness
#mouse integration
