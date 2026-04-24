class_name StorytellingManager

extends Node

@onready var stories_menu: CanvasLayer = $"../StoriesMenu"
@onready var waiting_menu: VBoxContainer = $"../StoriesMenu/WaitingMenu"

@onready var word_entry_menu: VBoxContainer = $"../StoriesMenu/WordEntryMenu"
@onready var word_entry: LineEdit = $"../StoriesMenu/WordEntryMenu/WordEntry"
@onready var submit_word: Button = $"../StoriesMenu/WordEntryMenu/SubmitWord"

@onready var waiting: Label = $"../StoriesMenu/WaitingMenu/Waiting"
@onready var tell_story: Button = $"../StoriesMenu/WaitingMenu/TellStory"
@export var logs: Array[SittingLog]
@onready var campfire: Node3D = $"../Level/Campfire"

@export var line: Label3D
@export var story_status : int = 0

var voices = DisplayServer.tts_get_voices_for_language("en")
var voice_id = voices[0]

@onready var word_request: HTTPRequest = $WordRequest

var telling_story = false
var adding_words = false

signal all_seated_for_story
signal ready_to_tell_story
signal all_completed_story

func _ready() -> void:
	all_seated_for_story.connect(_when_story_ready.rpc)
	ready_to_tell_story.connect(_campfire_telling_story.rpc)
	all_completed_story.connect(_on_all_completed_story.rpc)

func _on_sitting_log_sit() -> void:
	_when_sat_on_log()

func _on_sitting_log_2_sit() -> void:
	_when_sat_on_log()

func _when_sat_on_log() -> void:
	stories_menu.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if PlayerNetwork.players.values().all(func(p): return p.player_info.is_sitting):
		all_seated_for_story.emit()

@rpc("any_peer", "call_local")
func _when_story_ready():
	waiting.hide()
	tell_story.disabled = false

func _on_exit_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var player = PlayerNetwork.get_current_player()
	
	stories_menu.hide()
	waiting_menu.show()
	
	for l in logs:
		if l.occupied_by == player.name:
			player.player_info.is_sitting = false
			l.stand_up(player)
			break
	
	_leave_log.rpc()

@rpc("any_peer", "call_local")
func _leave_log() -> void:
	waiting.show()

	tell_story.disabled = true

func _on_campfire_story_complete() -> void:
	telling_story = false
	StoryManager.chosen_story = null
	StoryManager.words = {}
	_on_exit_pressed()

func _on_tell_story_pressed() -> void:
	_tell_story.rpc()

@rpc("any_peer", "call_local")
func _tell_story():
	var player = PlayerNetwork.get_current_player()

	StoryManager.select_story.rpc()
	
	await StoryManager.story_chosen
	
	#stories_menu.hide()
	waiting_menu.hide()
	word_entry_menu.show()
	
	player.player_info.adding_words = true
	_sync_player_adding_words.rpc(player, true)
	
	var idx: int = PlayerNetwork.get_player_index(player)
	var skip_amount: int = PlayerNetwork.players.size()

	while idx < StoryManager.words.size():
		var key = StoryManager.words.keys()[idx]
		
		submit_word.text = "random"
		word_entry.placeholder_text = StoryManager.words[key]
		
		await submit_word.pressed
		
		var new_word = word_entry.text
		
		if new_word == "":
			new_word = await get_random_word(StoryManager.words[key])
		
		word_entry.text = ""
		
		StoryManager.words[key] = new_word
		
		_sync_story_state.rpc(idx, new_word)
		idx += skip_amount
	
	word_entry_menu.hide()
	
	player.player_info.adding_words = false
		
	if PlayerNetwork.players.values().all(func(p): return !p.player_info.adding_words):
		ready_to_tell_story.emit()

func get_random_word(type: String) -> String:
	return await word_request.get_word(type)

func _on_word_entry_text_changed(new_text: String) -> void:
	if new_text == "":
		submit_word.text = "random"
	else:
		submit_word.text = "submit"

@rpc("any_peer", "call_local", "reliable")
func _on_all_completed_story() -> void:
	_on_campfire_story_complete()

@rpc("any_peer", "call_local", "reliable")
func _sync_story_state(idx: int, word: String) -> void:
	var key = StoryManager.words.keys()[idx]
	StoryManager.words[key] = word

@rpc("any_peer", "call_local")
func _sync_player_adding_words(player: Player, info: bool):
	player.player_info.adding_words = info

@rpc("any_peer", "call_local")
func _campfire_telling_story():
	telling_story = true
	
	StoryManager.chosen_story.words = StoryManager.words
	StoryManager.update_story()
	
	var player = PlayerNetwork.get_current_player()
	player.player_info.listening_to_story = true
	
	rpc("_sync_player_listening_state", int(player.name), true)
	
	progress_story()

@rpc("any_peer", "call_local", "reliable")
func _sync_player_listening_state(id: int, state: bool):
	var player = PlayerNetwork.get_player_by_name(str(id))
	
	if player:
		player.player_info.listening_to_story = state
	

func _unhandled_input(event: InputEvent) -> void:
	if !telling_story:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				DisplayServer.tts_stop()
				progress_story()

@rpc("call_local", "any_peer", "reliable")
func progress_story() -> void:
	if !StoryManager.chosen_story:
		return
		
	if story_status < len(StoryManager.chosen_story.story):
		var current_line = StoryManager.chosen_story.story[story_status]
		line.text = current_line
		
		story_status += 1
		
		DisplayServer.tts_speak(current_line, voice_id)
		DisplayServer.tts_set_utterance_callback(DisplayServer.TTS_UTTERANCE_ENDED, func(_id: int): progress_story())

	else:
		line.text = ""
		story_status = 0
		
		telling_story = false
		
		var player = PlayerNetwork.get_current_player()
		player.player_info.listening_to_story = false
		
		rpc("_sync_player_listening_state", int(player.name), false)
		
		if PlayerNetwork.players.values().all(func(p): return !p.player_info.listening_to_story):
			all_completed_story.emit()
		return
