extends Node3D

@onready var interactable: Area3D = $Interactable
@onready var sit_marker: Marker3D = $SitMarker
@onready var collision_shape_3d: CollisionShape3D = $InteractingComponent/InteractRange/CollisionShape3D

@export var occupied_by: String = ""

func _ready() -> void:
	interactable.interact = _on_interact	

func _on_interact() -> void:
	var player := PlayerNetwork.get_current_player()
		
	if occupied_by == "":
		_sit_down(player)
	elif occupied_by == player.name:
		_stand_up(player)

func _sit_down(player):
	player.global_position = sit_marker.global_position
	player.get_node("3DGodotRobot").rotation.y = rotation.y
	
	player.sit()

	_set_occupied.rpc(player.name)

func _stand_up(player):
	player.stand()
	_set_occupied.rpc("")

@rpc("any_peer", "call_local")
func _set_occupied(name: String):
	occupied_by = name
