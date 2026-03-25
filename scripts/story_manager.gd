extends Node

@export var chosen_story : Story
var chosen_story_index: int = -1
var words: Dictionary = {}

signal story_chosen
signal story_updated

var stories := [
	preload("res://scripts/stories/story_one.gd"),
	preload("res://scripts/stories/story_two.gd"),
]

@rpc("any_peer")
func select_story() -> void:
	if is_multiplayer_authority():
		var idx := randi() % stories.size()
		chosen_story_index = idx
		set_story.rpc(idx)

@rpc("authority", "call_local")
func set_story(idx: int) -> void:
	chosen_story = stories[idx].new()
	chosen_story_index = idx
	words = chosen_story.words
	story_chosen.emit()

@rpc("any_peer", "reliable")
func update_story_word(idx: int, word: String) -> void:
	var key : String = chosen_story.words.keys()[idx]
		
	chosen_story.words[key] = word
	
	_sync_story_word.rpc(key, word)

@rpc("authority", "call_local", "reliable")
func _sync_story_word(key: String, word: String) -> void:
	chosen_story.words[key] = word

func update_story():
	chosen_story.update_story()
