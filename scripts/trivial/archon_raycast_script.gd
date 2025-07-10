extends RAYCASTREACTIVE

func interact_By_Player(player):
	var root = $"../.."
	root.get_Talked_To(player)
