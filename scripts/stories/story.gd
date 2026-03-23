@abstract
class_name Story extends Node

@export var story : Array[String]
@export var words : Dictionary[String, String]

func get_word(idx: int) -> String:
	var key : String = words.keys()[idx]
	
	return words[key]
	
func set_word(idx: int, word: String) -> void:
	var key : String = words.keys()[idx]
	
	words[key] = word
