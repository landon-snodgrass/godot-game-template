extends Node

var music_player: AudioStreamPlayer;
var queued_music_player: AudioStreamPlayer;

var ambient_players: Array[AudioStreamPlayer] = [];
var sfx_players: Array[AudioStreamPlayer] = [];
var ui_players: Array[AudioStreamPlayer] = [];

# Pool sizes
const MAX_AMBIENT_PLAYERS = 6;
const MAX_SFX_PLAYERS = 16;
const MAX_UI_PLAYERS = 8;

# Current state
var current_music: AudioStream
var ambient_sources: Dictionary = {}
var next_ambient_id: int = 0


func _ready() -> void:
	_setup_audio_players()


func _setup_audio_players() -> void:
	# Music players
	music_player = AudioStreamPlayer.new();
	music_player.bus = "Music";
	add_child(music_player);

	queued_music_player = AudioStreamPlayer.new()
	queued_music_player.bus = "Music";
	add_child(queued_music_player);

	# Ambient players pool
	for i in range(MAX_AMBIENT_PLAYERS):
		var player = AudioStreamPlayer.new();
		player.bus = "Ambient";
		add_child(player)
		ambient_players.append(player);

	# SFX players pool
	for i in range(MAX_SFX_PLAYERS):
		var player = AudioStreamPlayer.new();
		player.bus = "SFX";
		add_child(player);
		sfx_players.append(player);

	# UI players pool
	for i in range(MAX_UI_PLAYERS):
		var player = AudioStreamPlayer.new();
		player.bus = "UI";
		add_child(player);
		ui_players.append(player);


func play_music(stream: AudioStream, fade_time: float = 1.0) -> void:
	if not stream:
		return;

	current_music = stream;

	if fade_time > 0.0 and music_player.playing:
		var tween = create_tween();
		tween.set_parallel(true);
		tween.tween_property(music_player, "volume_linear", 0.0, fade_time);

		queued_music_player.stream = stream
		queued_music_player.volume_linear = 0;
		queued_music_player.play()
		tween.tween_property(queued_music_player, "volume_linear", 1.0, fade_time);

		tween.tween_callback(_swap_music_players).set_delay(fade_time);
	else:
		music_player.stream = stream;
		music_player.volume_linear = 1.0;
		music_player.play();


func play_music_intro_loop(intro_stream: AudioStream, loop_stream: AudioStream, fade_time: float = 1.0) -> void:
	if not intro_stream or not loop_stream:
		return;

	current_music = loop_stream;

	# Stop current music
	if music_player.playing:
		stop_music(fade_time);
		await get_tree().create_timer(fade_time).timeout

	music_player.stream = intro_stream;
	music_player.volume_linear = 1.0;
	music_player.play();

	music_player.finished.connect(_on_intro_finished.bind(loop_stream), CONNECT_ONE_SHOT);


func _on_intro_finished(loop_stream: AudioStream) -> void:
	music_player.stream = loop_stream;
	music_player.play();


func stop_music(fade_time: float = 1.0) -> void:
	if fade_time > 0.0 and music_player.playing:
		var tween = create_tween();
		tween.tween_property(music_player, "volume_linear", 0.0, fade_time);
		tween.tween_callback(music_player.stop);
	else:
		music_player.stop();


func pause_music() -> void:
	music_player.stream_paused = true;


func resume_music() -> void:
	music_player.stream_paused = false;


## TODO: is this right?
func _swap_music_players() -> void:
	music_player.stop();
	var temp = music_player;
	music_player = queued_music_player;
	queued_music_player = temp;


# Ambient Sounds
func play_ambience(stream: AudioStream, volume_linear: float = 1.0, fade_in: float = 0.0) -> int:
	if not stream:
		return -1;

	var player = _get_available_ambient_player()
	if not player:
		print("No available players");
		return -1;

	var ambient_id = next_ambient_id;
	next_ambient_id += 1;

	player.stream = stream;
	player.volume_linear = volume_linear if fade_in == 0.0 else 0.0;
	player.play();

	ambient_sources[ambient_id] = player

	if fade_in > 0.0:
		var tween = create_tween();
		tween.tween_property(player, "volume_linear", volume_linear, fade_in);

	return ambient_id;


func stop_ambience(ambient_id: int, fade_out: float = 0.0) -> void:
	if not ambient_sources.has(ambient_id):
		return;

	var player = ambient_sources[ambient_id]
	ambient_sources.erase(ambient_id);

	if fade_out > 0.0:
		var tween = create_tween();
		tween.tween_property(player, "volume_linear", 0.0, fade_out);
		tween.tween_callback(player.stop);
	else:
		player.stop();


func stop_all_ambiences(fade_out: float = 0.0) -> void:
	for ambient_id in ambient_sources.keys():
		stop_ambience(ambient_id, fade_out);


func _get_available_ambient_player() -> AudioStreamPlayer:
	for player in ambient_players:
		if not player.playing:
			return player;
	return null;


# SFX
func play_sfx(stream: AudioStream, volume_linear: float = 1.0) -> void:
	if not stream:
		return;

	var player = _get_available_sfx_player();
	if not player:
		player = sfx_players[0];

	player.stream = stream;
	player.volume_linear = volume_linear;
	player.play();


func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player;
	return null;


# UI SFX
func play_ui_sfx(stream: AudioStream, volume_linear: float = 1.0) -> void:
	if not stream:
		return;

	var player = _get_available_ui_player()
	if not player:
		player = ui_players[0]

	player.stream = stream;
	player.volume_linear = volume_linear;
	player.play();


func _get_available_ui_player() -> AudioStreamPlayer:
	for player in ui_players:
		if not player.playing:
			return player;
	return null


# Debug helpers
func _get_debug_info() -> Dictionary:
	return {
		"music_playing": music_player.playing,
		"current_music": current_music.resource_path if current_music else "None",
		"active_ambience": ambient_sources.size(),
		"available_sfx": _get_available_sfx_count(),
		"available_ui": _get_available_ui_count(),
	}


func _get_available_sfx_count() -> int:
	var count = 0;
	for player in sfx_players:
		if not player.playing:
			count += 1;
	return count;


func _get_available_ui_count() -> int:
	var count = 0;
	for player in ui_players:
		if not player.playing:
			count += 1;
	return count;
