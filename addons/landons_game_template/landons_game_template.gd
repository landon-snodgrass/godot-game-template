@tool
extends EditorPlugin


const TRANSITION_AUTOLOAD_NAME = "Transitions";
const SAVE_MANAGER_AUTOLOAD_NAME = "SaveManager";
const MAIN_INSTANCES_AUTOLOAD_NAME = "MainInstances";
const SETTINGS_MANAGER_AUTOLOAD_NAME = "SettingsManager";
const AUDIO_MANAGER_AUTOLOAD_NAME = "AudioManager";
const PAUSE_MANAGER_AUTOLOAD_NAME = "PauseManager";


var old_default_bus_layout: AudioBusLayout
var default_layout_path: String


func _enter_tree() -> void:
	add_autoload_singleton(TRANSITION_AUTOLOAD_NAME, "res://addons/landons_game_template/system_managers/transitions.tscn");
	add_autoload_singleton(SAVE_MANAGER_AUTOLOAD_NAME, "res://addons/landons_game_template/system_managers/save_manager.gd");
	add_autoload_singleton(MAIN_INSTANCES_AUTOLOAD_NAME, "res://addons/landons_game_template/system_managers/main_instances.gd");
	add_autoload_singleton(SETTINGS_MANAGER_AUTOLOAD_NAME, "res://addons/landons_game_template/system_managers/settings_manager.gd");
	add_autoload_singleton(AUDIO_MANAGER_AUTOLOAD_NAME, "res://addons/landons_game_template/system_managers/audio_manager.gd");
	add_autoload_singleton(PAUSE_MANAGER_AUTOLOAD_NAME, "res://addons/landons_game_template/system_managers/pause_manager.tscn");

	var icon = load("res://addons/landons_game_template/spark-full-gray.svg");
	var script: Script = load("res://addons/landons_game_template/game_runner.gd");
	add_custom_type("GameRunner", "Node", script, icon);

	var default_bus_layout = load("res://addons/landons_game_template/default_bus_layout.tres");
	default_bus_layout = default_bus_layout.duplicate(true);
	var default_layout_path = ProjectSettings.get_setting("audio/buses/default_bus_layout")
	if ResourceLoader.exists(default_layout_path):
		_setup_audio_buses(default_layout_path);
	else:
		AudioServer.set_bus_layout(default_bus_layout)


func _exit_tree() -> void:
	remove_autoload_singleton(TRANSITION_AUTOLOAD_NAME);
	remove_autoload_singleton(SAVE_MANAGER_AUTOLOAD_NAME);
	remove_autoload_singleton(MAIN_INSTANCES_AUTOLOAD_NAME);
	remove_autoload_singleton(SETTINGS_MANAGER_AUTOLOAD_NAME);
	remove_autoload_singleton(AUDIO_MANAGER_AUTOLOAD_NAME);
	remove_autoload_singleton(PAUSE_MANAGER_AUTOLOAD_NAME);
	if old_default_bus_layout:
		AudioServer.set_bus_layout(old_default_bus_layout);
	else:
		AudioServer.set_bus_layout(null);


func _setup_audio_buses(default_layout_path: String) -> void:
	default_layout_path = ProjectSettings.get_setting("audio/buses/default_bus_layout", "res://default_bus_layout.tres")
	var plugin_bus_layout = load("res://addons/landons_game_template/default_bus_layout.tres")

	if not ResourceLoader.exists(default_layout_path):
		# User has no default bus layout - use ours
		print("No existing bus layout found, using plugin default")
		var new_layout = plugin_bus_layout.duplicate(true)
		ResourceSaver.save(new_layout, default_layout_path)
		AudioServer.set_bus_layout(new_layout)
		old_default_bus_layout = null  # No previous layout to restore
	else:
		# User has existing layout - modify it to include our buses
		print("Existing bus layout found, adding required buses")
		var existing_layout: AudioBusLayout = load(default_layout_path)
		old_default_bus_layout = existing_layout.duplicate(true)  # Save original for restoration

		var modified_layout = existing_layout.duplicate(true)
		var buses_needed = ["Ambient", "SFX", "UI", "Music"]
		var buses_added = []

		for bus_name in buses_needed:
			if modified_layout.find_bus(bus_name) == -1:
				modified_layout.add_bus(bus_name)
				buses_added.append(bus_name)

		if buses_added.size() > 0:
			print("Added audio buses: ", buses_added)
			ResourceSaver.save(modified_layout, default_layout_path)
			AudioServer.set_bus_layout(modified_layout)
		else:
			print("All required buses already exist")


func _restore_audio_buses() -> void:
	if old_default_bus_layout:
		# Restore the original layout
		print("Restoring original bus layout")
		ResourceSaver.save(old_default_bus_layout, default_layout_path)
		AudioServer.set_bus_layout(old_default_bus_layout)
	else:
		# There was no original layout, create an empty one or use default
		print("Creating default bus layout (user had none originally)")
		var empty_layout = AudioBusLayout.new()
		# This creates a layout with just the Master bus, which is the Godot default
		ResourceSaver.save(empty_layout, default_layout_path)
		AudioServer.set_bus_layout(empty_layout)
