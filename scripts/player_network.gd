extends Node

@export var players: Dictionary

func get_current_player() -> Player:
	var id := get_tree().get_multiplayer().get_unique_id()
	
	return get_player_by_name(str(id))

func get_player_by_name(name: String) -> Player:
	if players.has(name):
		return players[name]
	
	return null
