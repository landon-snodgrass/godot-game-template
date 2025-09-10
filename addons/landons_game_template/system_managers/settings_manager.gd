extends Node


const PRODUCTION_PATH = "user://settings.cfg";
const TEST_PATH = "res://settings.cfg";

var SETTINGS_PATH = TEST_PATH;

var config: ConfigFile
var available_resolutions: Array[Vector2i] = [
	Vector2i(1920, 1080),
	Vector2i(1600, 900),
	Vector2i(1366, 768),
	Vector2i(1280, 720)
];

var fullscreen: bool = false;
var vsync: bool = true;
var resolution_index: int = 0;
var master_volume: float = 1.0;
var music_volume: float = 1.0;
var sfx_volume: float = 1.0;
var ui_volume: float = 1.0;
var ambient_volume: float = 1.0;

func _ready() -> void:
	config = ConfigFile.new();
	load_settings();
	apply_all_settings();


func load_settings() -> void:
	if config.load(SETTINGS_PATH) != OK:
		# No settings save defaults
		save_settings();
		return

	# Load from config file
	fullscreen = config.get_value("graphics", "fullscreen", false);
	vsync = config.get_value("graphics", "vsync", true);
	resolution_index = config.get_value("graphics", "resolution_index", 0);
	master_volume = config.get_value("audio", "master_volume", 1.0);
	music_volume = config.get_value("audio", "music_volume", 1.0);
	sfx_volume = config.get_value("audio", "sfx_volume", 1.0);
	ui_volume = config.get_value("audio", "ui_volume", 1.0);
	ambient_volume = config.get_value("audio", "ambient_volume", 1.0);

func save_settings() -> void:
	config.set_value("graphics", "fullscreen", fullscreen);
	config.set_value("graphics", "vsync", vsync);
	config.set_value("graphics", "resolution_index", resolution_index);
	config.set_value("audio", "master_volume", master_volume);
	config.set_value("audio", "music_volume", music_volume);
	config.set_value("audio", "sfx_volume", sfx_volume);
	config.set_value("audio", "ui_volume", ui_volume);
	config.set_value("audio", "ambient_volume", ambient_volume);

	config.save(SETTINGS_PATH);

func apply_all_settings() -> void:
	apply_graphics_settings();
	apply_audio_settings();


func apply_graphics_settings() -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED);

	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED
	)

	if resolution_index < available_resolutions.size():
		var res = available_resolutions[resolution_index]
		DisplayServer.window_set_size(res);


func apply_audio_settings() -> void:
	var master_bus = AudioServer.get_bus_index("Master");
	var music_bus = AudioServer.get_bus_index("Music");
	var sfx_bus = AudioServer.get_bus_index("SFX");
	var ui_bus = AudioServer.get_bus_index("UI");
	var ambient_bus = AudioServer.get_bus_index("Ambient");

	AudioServer.set_bus_volume_linear(master_bus, master_volume)

	if music_bus != -1:
		AudioServer.set_bus_volume_linear(music_bus, music_volume)

	if sfx_bus != -1:
		AudioServer.set_bus_volume_linear(sfx_bus, sfx_volume);

	if ui_bus != -1:
		AudioServer.set_bus_volume_linear(ui_bus, ui_volume);

	if ambient_bus != -1:
		AudioServer.set_bus_volume_linear(ambient_bus, ambient_volume)


func set_fullscreen(enabled: bool) -> void:
	fullscreen = enabled;
	apply_graphics_settings()
	save_settings();


func set_resolution(index: int) -> void:
	resolution_index = index;
	apply_graphics_settings();
	save_settings();

func set_vsync(enabled: bool) -> void:
	vsync = enabled;
	apply_graphics_settings()
	save_settings();


func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0);
	apply_audio_settings()
	save_settings();


func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0);
	apply_audio_settings();
	save_settings();


func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0);
	apply_audio_settings();
	save_settings();


func set_ui_volume(volume: float) -> void:
	ui_volume = clamp(volume, 0.0, 1.0);
	apply_audio_settings();
	save_settings();


func set_ambient_volume(volume: float) -> void:
	ambient_volume = clamp(volume, 0.0, 1.0);
	apply_audio_settings()
	save_settings();


func get_resolution_string(index: int) -> String:
	if index < available_resolutions.size():
		var res = available_resolutions[index]
		return str(res.x) + "x" + str(res.y)
	return "Unknown"


func get_current_resolution_string() -> String:
	return get_resolution_string(resolution_index)
