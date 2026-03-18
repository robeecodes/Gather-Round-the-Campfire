extends Node

@export var players: Array[Player] = []

func get_current_player() -> Player:
	var id := get_tree().get_multiplayer().get_unique_id()
	
	for p in PlayerNetwork.players:
		if p.name == str(id):
			return p
	
	return null
