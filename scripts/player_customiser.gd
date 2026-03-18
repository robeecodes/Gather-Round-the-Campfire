extends Control

@onready var options: OptionButton = $VBoxContainer/OptionButton
@onready var player: Player = $Player

@onready var main := preload("res://scenes/game.tscn")

func _on_confirm_customisation_pressed() -> void:
	get_tree().change_scene_to_packed(main)

func _on_option_button_item_selected(index: int) -> void:
	var skin: String = options.get_item_text(options.get_selected_id())
	PlayerNetwork.player_skin_colour = skin
	player.set_player_skin(PlayerNetwork.player_skin_colour)
