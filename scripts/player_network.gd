extends Node

@export var players: Dictionary

func get_current_player() -> Player:
	var id := get_tree().get_multiplayer().get_unique_id()
	
	return get_player_by_name(str(id))

func get_player_by_name(p_name: String) -> Player:
	if players.has(p_name):
		return players[p_name]
	
	return null

func get_player_index(player: Player) -> int:
	return players.keys().find(player.name)
