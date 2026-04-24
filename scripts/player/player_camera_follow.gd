extends Camera3D

## Third person camera code based on Octodemy (2024) - See 'Code References' in README

@export var spring_arm: Node3D
@export var lerp_power: float = 1.0

func _process(delta: float) -> void:
	position = lerp(position, spring_arm.position, delta*lerp_power)
