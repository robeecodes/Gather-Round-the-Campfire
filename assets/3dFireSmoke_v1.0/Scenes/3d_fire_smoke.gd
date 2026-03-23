extends Node3D

@onready var interactable: Area3D = $Interactable
@onready var _3d_fire: MeshInstance3D = $"3DFire"
@onready var omni_light_3d: OmniLight3D = $OmniLight3D

func _ready() -> void:
	interactable.interact = _on_interact.rpc

@rpc("call_local", "any_peer", "reliable")
func _on_interact() -> void:
	_3d_fire.show()
	omni_light_3d.show()
	interactable.is_interactable = false
