extends raycast_reactive

func interact_By_Player(player)->bool:
	var root = $"../.."
	root.get_Talked_To(player)
	return false
