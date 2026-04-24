class_name Player
extends CharacterBody3D

@onready var animation_player := $"3DGodotRobot/AnimationPlayer"
@onready var godot_robot := $"3DGodotRobot"
@onready var marker := $SpringArmPivot/Camera3D/Marker3D

@export var camera: Camera3D

@export_category("Speed")
@export var max_speed: float = 2.5
@export var acceleration: float = 25.0

enum Skin_Colour {BLUE, GREEN, RED, YELLOW}
@onready var body_parts := [
	get_node("3DGodotRobot/RobotArmature/Skeleton3D/Bottom"),
	get_node("3DGodotRobot/RobotArmature/Skeleton3D/Chest"),
	get_node("3DGodotRobot/RobotArmature/Skeleton3D/Face"),
	get_node("3DGodotRobot/RobotArmature/Skeleton3D/Llimbs and head")
]

@export_category("Skin Colours")
@export var skin_textures: Dictionary[Skin_Colour, CompressedTexture2D]

enum Hat_Type {NONE, FROG, COWBOY, MUSHROOM, PROPELLOR}

@export_category("Accessories")
@export var hats : Dictionary[Hat_Type, PackedScene]

const JUMP_VELOCITY = 4.5

@export var player_info := {
	skin_colour = Skin_Colour.BLUE,
	accessories = {
		hat = Hat_Type.NONE
	},
	is_sitting = false,
	adding_words = false,
	listening_to_story = false
}

# Foot colliders for audio
@onready var foot_a: Area3D = $"3DGodotRobot/RobotArmature/Skeleton3D/Foot_Collider_A/Area3D"
@onready var foot_b: Area3D = $"3DGodotRobot/RobotArmature/Skeleton3D/Foot_Collider_B/Area3D"

var feet_touching_ground = false

@export_category("SFX")
@export var footstep_grass_sounds: Array[AudioStreamMP3]

@onready var footstep_player: AudioStreamPlayer3D = $FootstepPlayer


func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

func _ready() -> void:
	animation_player.play("Idle")
	if is_multiplayer_authority():
		camera.make_current()

func _process(_delta):
	var touching_areas = foot_a.get_overlapping_areas() + foot_b.get_overlapping_areas()
	var is_touching = foot_a.get_overlapping_areas().size() > 0 or foot_b.get_overlapping_areas().size() > 0
	
	if is_touching and not feet_touching_ground and is_on_floor():
		play_footstep_sound(_get_surface_type(touching_areas))
		feet_touching_ground = true
	elif not is_touching:
		feet_touching_ground = false

func _get_surface_type(areas: Array) -> String:
	for area in areas:
		if area.name == "grass":
			return "grass"
			
	return "default"

func play_footstep_sound(surface_type: String) -> void:
	var sounds: Array[AudioStreamMP3] = []
	
	#if surface_type == "grass":
	sounds = footstep_grass_sounds
	
	if sounds.is_empty():
		return
	
	var random_sound = sounds[randi() % sounds.size()]
	footstep_player.stream = random_sound
	footstep_player.volume_db = -12
	footstep_player.play()

## Character controller movement support based on Gwizz (2023) - see 'Code References' in README

func _physics_process(delta: float) -> void:	
	if !is_multiplayer_authority():
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir := Input.get_vector(&"Player_Left", &"Player_Right", &"Player_Forwards", &"Player_Backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		direction = direction.rotated(Vector3.UP, camera.global_rotation.y)
		
		direction *= max_speed
		
		velocity.x = move_toward(velocity.x, direction.x, delta * acceleration)
		velocity.z = move_toward(velocity.z, direction.z, delta * acceleration)
		animation_player.play("Run")
		
		var look_position := global_position + Vector3(velocity.x, 0, velocity.z)
		godot_robot.look_at(look_position, Vector3.UP, true)
		
	else:
		velocity.x = move_toward(velocity.x, 0, max_speed)
		velocity.z = move_toward(velocity.z, 0, max_speed)
		animation_player.play("Idle")

	move_and_slide()
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.slide(collision.get_normal())

func sit() -> void:
	animation_player.play("Idle")
	set_physics_process(false)
	player_info.is_sitting = true

func stand() -> void:
	set_physics_process(true)

## CUSTOMISATION FUNCTIONS
# SKIN
## Code to set skin and mesh texture based on crizmo (2025) - See 'Code References' in README
@rpc("any_peer", "reliable")
func set_player_skin(skin_id: int) -> void:
	var texture = skin_textures[skin_id]
	
	for part in body_parts:
		set_mesh_texture(part, texture)
	
func set_mesh_texture(mesh_instance: MeshInstance3D, texture: CompressedTexture2D) -> void:
	if mesh_instance:
		var material := mesh_instance.get_surface_override_material(0)
		if material and material is StandardMaterial3D:
			var new_material := material
			new_material.albedo_texture = texture
			mesh_instance.set_surface_override_material(0, new_material)

# HAT
@rpc("any_peer", "reliable")
func set_player_hat(hat_id: int) -> void:
	var hat_node: Node3D = $"3DGodotRobot/RobotArmature/Skeleton3D/BoneAttachment3D/Hat_Node"
	if hat_node.get_child_count() > 0:
		for child in hat_node.get_children():
			hat_node.remove_child(child)
			child.queue_free()
			
	if hat_id == Hat_Type.NONE:
		return
	
	var new_hat = hats[player_info.accessories.hat].instantiate()
	hat_node.add_child(new_hat)
