# goes onto an audio_controller with an AudioStreamPlayer (mic input) child
extends Node

## VoIP code based on passthecodine (2023) - See 'Code References' in README

@onready var input: AudioStreamPlayer = $Input
var idx : int
var effect : AudioEffectCapture
var playback : AudioStreamGeneratorPlayback
@onready var output: AudioStreamPlayer3D = $Output

var buffer_size = 1024

var mic_active = false

func _ready() -> void:
	
	# we only want to initalize the mic for the peer using it
	if (is_multiplayer_authority()):
		input.stream = AudioStreamMicrophone.new()
		input.play()
		idx = AudioServer.get_bus_index("Record")
		effect = AudioServer.get_bus_effect(idx, 0)
		# replace 0 with whatever index the capture effect is
			
	# playback variable will be needed for playback on other peers	
	playback = output.get_stream_playback()

func _process(_delta: float) -> void:
	if (not is_multiplayer_authority() or not mic_active): 
		return
	if (effect.can_get_buffer(buffer_size) && playback.can_push_buffer(buffer_size)):
		send_data.rpc(effect.get_buffer(buffer_size))
	effect.clear_buffer()

@rpc("any_peer", "call_remote", "reliable")
func send_data(data : PackedVector2Array):
	for i in range(0,buffer_size):
		playback.push_frame(data[i])


func _on_mic_toggle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		mic_active = true
	else:
		mic_active = false
