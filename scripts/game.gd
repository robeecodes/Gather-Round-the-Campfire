class_name Game
extends Node

@onready var menu := $Menu

# Customisation options
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var skin_colour_option: OptionButton = $PauseMenu/VSplitContainer/SkinColour
@onready var hat_option: OptionButton = $PauseMenu/VSplitContainer/Hat

const PLAYER := preload("res://scenes/player.tscn")

@onready var join_code: LineEdit = $Menu/Control/VBoxContainer/JoinCode
@onready var host_oid_label: Label = $PauseMenu/HBoxContainer/host_oid

#var voices = DisplayServer.tts_get_voices_for_language("en")
#var voice_id = voices[0]

func _ready() -> void:
	Multiplayer.config_noray()
	Multiplayer.hosted.connect(_on_host_connected)
	Multiplayer.joined.connect(_on_client_connected)
	$MultiplayerSpawner.spawn_function = add_player
	
func _on_host_pressed() -> void:
	#var peer := ENetMultiplayerPeer.new()
	#peer.create_server(25565)
	#multiplayer.multiplayer_peer = peer
	
	Multiplayer.host()

func _on_host_connected() -> void:
	host_oid_label.text = Multiplayer.external_oid
	
	multiplayer.peer_connected.connect(
		func(pid): 
			print("Peer ID: " + str(pid) + " has joined the game.")
			$MultiplayerSpawner.spawn(pid)
	)
	
	$MultiplayerSpawner.spawn(multiplayer.get_unique_id())
	
	#DisplayServer.tts_speak("ni howdy", voice_id)
	
	menu.hide()

func _on_join_pressed() -> void:
	#var peer := ENetMultiplayerPeer.new()
	#peer.create_client("localhost", 25565)
	#multiplayer.multiplayer_peer = peer
	
	Multiplayer.join(join_code.text)

func _on_client_connected() -> void:
	host_oid_label.text = Multiplayer.external_oid
	#DisplayServer.tts_speak("ni howdy", voice_id)
	menu.hide()

func _on_copy_oid_pressed() -> void:
	print(Multiplayer.external_oid)
	DisplayServer.clipboard_set(Multiplayer.external_oid)

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
