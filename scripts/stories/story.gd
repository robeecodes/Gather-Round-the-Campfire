@abstract
class_name Story extends Node

@export var story : Array[String]
@export var words : Dictionary[String, String]

func get_word(idx: int) -> String:
	var key : String = words.keys()[idx]
	
	return words[key]

@rpc("any_peer", "reliable")
func set_word(idx: int, word: String) -> void:
	var key : String = words.keys()[idx]
		
	words[key] = word
	_sync_word.rpc(idx, word)

@rpc("authority", "call_local", "reliable")
func _sync_word(idx: int, word: String) -> void:
	var key : String = words.keys()[idx]
	words[key] = word
