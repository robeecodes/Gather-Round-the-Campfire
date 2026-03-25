class_name Game
extends Node

@onready var menu := $Menu

# Customisation options
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var skin_colour_option: OptionButton = $PauseMenu/VSplitContainer/SkinColour
@onready var hat_option: OptionButton = $PauseMenu/VSplitContainer/Hat

# Campfire options
@export var stories_menu: CanvasLayer
@onready var waiting_menu: VBoxContainer = $StoriesMenu/WaitingMenu

@onready var word_entry_menu: VBoxContainer = $StoriesMenu/WordEntryMenu
@onready var word_entry: LineEdit = $StoriesMenu/WordEntryMenu/WordEntry
@onready var submit_word: Button = $StoriesMenu/WordEntryMenu/SubmitWord

@onready var waiting: Label = $StoriesMenu/WaitingMenu/Waiting
@onready var tell_story: Button = $StoriesMenu/WaitingMenu/TellStory
@export var logs: Array[SittingLog]
@onready var campfire: Node3D = $Level/Campfire

var telling_story = false
var adding_words = false

signal all_seated_for_story
signal ready_to_tell_story

const PLAYER := preload("res://scenes/player.tscn")

var peer := ENetMultiplayerPeer.new()

func _ready() -> void:
	$MultiplayerSpawner.spawn_function = add_player
	all_seated_for_story.connect(_when_story_ready.rpc)
	ready_to_tell_story.connect(_campfire_telling_story.rpc)
	
func _on_host_pressed() -> void:
	peer.create_server(25565)
	multiplayer.multiplayer_peer = peer
		
	multiplayer.peer_connected.connect(
		func(pid): 
			print("Peer ID: " + str(pid) + " has joined the game.")
			$MultiplayerSpawner.spawn(pid)
	)
	
	$MultiplayerSpawner.spawn(multiplayer.get_unique_id())
	
	menu.hide()

func _on_join_pressed() -> void:
	peer.create_client("localhost", 25565)
	multiplayer.multiplayer_peer = peer
	menu.hide()

func add_player(pid) -> Player:
	var player := PLAYER.instantiate()
	player.name = str(pid)
	player.global_position = $Level.get_child(PlayerNetwork.players.size()).global_position
	
	PlayerNetwork.players[player.name] = player
	
	for p in PlayerNetwork.players.values():
		p.set_player_skin(p.player_info.skin_colour)
		#### Sync to all other peers
		rpc("sync_player_skin", int(p.name), p.player_info.skin_colour)
	
	return player

# Pause Menu
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause_menu.show()
		get_tree().paused = true
		

func _on_resume_pressed() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	pause_menu.hide()
	get_tree().paused = false

# Update Skin Colour
func _on_skin_colour_item_selected(index: int) -> void:
	var player := PlayerNetwork.get_current_player()
			
	var skin := skin_colour_option.get_selected_id()
	
	player.player_info.skin_colour = skin
	player.set_player_skin(skin)
	
	rpc("sync_player_skin", int(player.name), skin)

@rpc("any_peer", "call_local")
func sync_player_skin(id: int, skin: int):
	var player := PlayerNetwork.get_player_by_name(str(id))
	
	if player:
		player.player_info.skin_colour = skin
		player.set_player_skin(skin)

# Update Hat
func _on_hat_item_selected(index: int) -> void:
	var player := PlayerNetwork.get_current_player()
	
	var hat := hat_option.get_selected_id()
	
	player.player_info.accessories.hat = hat
	player.set_player_hat(hat)

# --------- STORYTELLING --------- #
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
	
	var player := PlayerNetwork.get_current_player()
	
	stories_menu.hide()
	waiting_menu.show()
	
	for log in logs:
		if log.occupied_by == player.name:
			log.stand_up(player)
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
		
		word_entry.placeholder_text = StoryManager.words[key]
		
		await submit_word.pressed
		
		if word_entry.text == "":
			continue
		
		var new_word = word_entry.text
		word_entry.text = ""
		
		StoryManager.words[key] = new_word
		
		_sync_story_state.rpc(idx, new_word)
		idx += skip_amount
	
	word_entry_menu.hide()
	
	player.player_info.adding_words = false
	_sync_player_adding_words.rpc(player, false)
		
	if PlayerNetwork.players.values().all(func(p): return !p.player_info.adding_words):
		ready_to_tell_story.emit()


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
	
	while telling_story:
		campfire.progress_story()
		await get_tree().create_timer(2).timeout
