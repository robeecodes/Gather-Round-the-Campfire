extends Node3D

@onready var interactable: Area3D = $Interactable
@onready var _3d_fire: MeshInstance3D = $"3DFire"
@onready var omni_light_3d: OmniLight3D = $OmniLight3D
@onready var line: Label3D = $Line

@export var story_status : int = 0

var voices = DisplayServer.tts_get_voices_for_language("en")
var voice_id = voices[0]

signal story_complete

func _ready() -> void:
	interactable.interact = _on_interact.rpc

@rpc("call_local", "any_peer", "reliable")
func _on_interact() -> void:
	_3d_fire.show()
	omni_light_3d.show()
	interactable.is_interactable = false

@rpc("call_local", "any_peer", "reliable")
func progress_story() -> void:
	if story_status < len(StoryManager.chosen_story.story):
		var current_line := StoryManager.chosen_story.story[story_status]
		line.text = current_line
		#DisplayServer.tts_speak(current_line, voice_id)
		
		#DisplayServer.tts_set_utterance_callack(TTS_UTTERANCE_ENDED,, )
		
	else:
		line.text = ""
		story_complete.emit()
		story_status = 0
		return
	
	story_status += 1
