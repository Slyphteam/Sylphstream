##Deprecated script, since I moved the generic "target hit" statement to the bullet reactive parent.
class_name testing_target extends raycast_reactive

func hit_By_Bullet(dam, damtype, dir, origin):
	print("Target hit! ", dam)
