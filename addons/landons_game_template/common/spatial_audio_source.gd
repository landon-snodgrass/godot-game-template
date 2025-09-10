class_name SpatialAudioSource
extends Node2D


@export var audio_stream: AudioStream;
@export var max_distance: float = 1000.0;
@export var volume_linear: float = 1.0;
@export var auto_play: bool = false;
@export var loop: bool = true;


@onready var audio_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new();


var is_playing: bool = false;


func _ready() -> void:
	add_child(audio_player);
	audio_player.stream = audio_stream;
	audio_player.volume_linear = volume_linear;
	audio_player.max_distance = max_distance;
	audio_player.bus = "SFX"

	if auto_play:
		play();


func play() -> void:
	if audio_stream:
		audio_player.play();
		is_playing = true;


func stop() -> void:
	audio_player.stop();
	is_playing = false;


func set_volume(volume_linear: float) -> void:
	audio_player.volume_linear = volume_linear;
