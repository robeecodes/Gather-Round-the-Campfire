class_name Game
extends Node

@onready var menu := $Menu

# Customisation options
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var skin_colour_option: OptionButton = $PauseMenu/VSplitContainer/SkinColour
@onready var hat_option: OptionButton = $PauseMenu/VSplitContainer/Hat

const PLAYER := preload("res://scenes/player.tscn")

@onready var join_code: LineEdit = $Menu/Control/VBoxContainer/JoinCode
@onready var host_oid_label: Label = $PauseMenu/VSplitContainer/HBoxContainer/host_oid
@onready var loading_label: Label = $Menu/Control/Loading
@onready var host_oid_box: HBoxContainer = $PauseMenu/VSplitContainer/HostOIDBox
@onready var noray_toggle: CheckButton = $Menu/Control/VBoxContainer/NorayToggleContainer/NorayToggle

var mode := "LAN"

func _ready() -> void:
	# Connect to noray in case noray is activated
	Multiplayer.config_noray()
	Multiplayer.hosted.connect(_on_host_connected)
	Multiplayer.joined.connect(_on_client_connected)
	Multiplayer.join_failed.connect(_on_client_connect_failed)
		
	$MultiplayerSpawner.spawn_function = add_player

func _on_noray_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		mode = "noray"
		join_code.show()
	else:
		mode = "LAN"
		join_code.hide()

func _on_host_pressed() -> void:
	noray_toggle.disabled = true
	Multiplayer.host(mode)

func _on_host_connected() -> void:
	if mode == "noray":
		host_oid_label.text = Multiplayer.external_oid
	else:
		host_oid_box.hide()
	
	multiplayer.peer_connected.connect(
		func(pid): 
			print("Peer ID: " + str(pid) + " has joined the game.")
			$MultiplayerSpawner.spawn(pid)
	)
	
	$MultiplayerSpawner.spawn(multiplayer.get_unique_id())
		
	menu.hide()

func _on_join_pressed() -> void:
	noray_toggle.disabled = true
	loading_label.show()
	Multiplayer.join(mode, join_code.text)

func _on_client_connected() -> void:
	if mode == "noray":
		host_oid_label.text = Multiplayer.external_oid
	else:
		host_oid_box.hide()
		
	menu.hide()

func _on_client_connect_failed() -> void:
	loading_label.text = "Connection Failed, Please Try Again"
	menu.show()

func add_player(pid) -> Player:
	var player = PLAYER.instantiate()
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
	var player = PlayerNetwork.get_current_player()
			
	var skin := skin_colour_option.get_selected_id()
	
	player.player_info.skin_colour = skin
	player.set_player_skin(skin)
	
	rpc("sync_player_skin", int(player.name), skin)

@rpc("any_peer", "call_local")
func sync_player_skin(id: int, skin: int):
	var player = PlayerNetwork.get_player_by_name(str(id))
	
	if player:
		player.player_info.skin_colour = skin
		player.set_player_skin(skin)

# Update Hat
func _on_hat_item_selected(index: int) -> void:
	var player = PlayerNetwork.get_current_player()
	
	var hat := hat_option.get_selected_id()
	
	player.player_info.accessories.hat = hat
	player.set_player_hat(hat)


func _on_copy_oid_pressed() -> void:
	DisplayServer.clipboard_set(Multiplayer.external_oid)
