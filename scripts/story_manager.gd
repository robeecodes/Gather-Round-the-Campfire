extends Node

@export var chosen_story : Story

var stories := [
	preload("res://scripts/stories/story_one.gd")
]

func select_story() -> void:
	chosen_story = stories.pick_random()
