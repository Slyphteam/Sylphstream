extends Node
#this is an ENTIRELY NONFUNCTIONAL script that just contains what I have or haven't done yet
#--KNOWN PROBLEMS:
#    Player seems to fall through the world if they're going too fast?
#    vector3 float runtimes will just happen due to playerVelocity
#    player CAN just look directly down and then phase through the ground through sheer force of will
# player cacn still do this?

#NEEDS DOING (in presumed  order of precedence):
#crouching
#figure out and get rid of whatever's causing the jitteriness
#fine-tuning to make it feel like gmod


#SORT OF DONE:
#sort out sourelike midair
#-- IMPORTANT SUBTASK: go over move_and_slide_sourcelike and jumping code with a fine tooth come
#-- hopefully this should solve our "falling through world" issues.
#mouse integration

# DIRECTORY OF WHERE SHIT IS:
# playertry2 is the ACTUAL implemented code that does things
# playerinput, playershared, and player_phys are all (mostly) copypasted from
# the godot3 and godot4 sourcelike projects people have worked on
