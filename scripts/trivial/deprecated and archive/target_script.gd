##Deprecated script, since I moved the generic "target hit" statement to the bullet reactive parent.
extends bullet_reactive

func hit_By_Bullet(dam, damtype, dir, origin):
	print("Target hit! ", dam)
