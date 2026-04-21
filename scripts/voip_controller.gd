# goes onto an audio_controller with an AudioStreamPlayer (mic input) child
extends Node

@onready var input: AudioStreamPlayer = $Input
var idx : int
var effect : AudioEffectCapture
var playback : AudioStreamGeneratorPlayback
@onready var output: AudioStreamPlayer3D = $Output

#func _enter_tree() -> void:
	#set_multiplayer_authority(int(str(name)))
	
func _ready() -> void:
	
	# we only want to initalize the mic for the peer using it
	if (is_multiplayer_authority()):
		print("HI")
		input.stream = AudioStreamMicrophone.new()
		input.play()
		idx = AudioServer.get_bus_index("Record")
		effect = AudioServer.get_bus_effect(idx, 0)
		# replace 0 with whatever index the capture effect is
			
	# playback variable will be needed for playback on other peers	
	playback = output.get_stream_playback()

func _process(delta: float) -> void:
	if (not is_multiplayer_authority()): 
		print("NONONO")
		return
	if (effect.can_get_buffer(512) && playback.can_push_buffer(512)):
		send_data.rpc(effect.get_buffer(512))
	effect.clear_buffer()

@rpc("any_peer", "call_remote", "reliable")
func send_data(data : PackedVector2Array):
	for i in range(0,512):
		playback.push_frame(data[i])
