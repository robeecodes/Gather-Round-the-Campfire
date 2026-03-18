extends Node3D

@onready var interactable: Area3D = $Interactable
@onready var fire: Node3D = $fire

func _ready() -> void:
	interactable.interact = _on_interact.rpc

@rpc("call_local", "any_peer", "reliable")
func _on_interact() -> void:
	fire.show()
	interactable.is_interactable = false
