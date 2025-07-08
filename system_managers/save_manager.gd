extends Node


const TEST_PATH := "res://game_save";
const PRODUCTION_PATH := "user://game_save";

var base_save_path := TEST_PATH;
var max_slots: int = 10;
var current_slot: int = 0;

var persistence_cache := {};
var save_data := {};
var save_systems: Dictionary[String, SystemSaveData]= {};


func get_save_path(slot: int) -> String:
	return base_save_path + "_slot_" + str(slot) + ".save";


func get_backup_path(slot: int) -> String:
	return base_save_path + "_slot_" + str(slot) + "_backup.save";


func register_system(key: String, save_data_object: SystemSaveData) -> void:
	save_systems[key] = save_data_object


func delete_slot(slot: int) -> void:
	var save_path = get_save_path(slot);
	var backup_path = get_backup_path(slot);

	if FileAccess.file_exists(save_path):
		DirAccess.remove_absolute(save_path);
	if FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(backup_path);


func save_game(slot: int = -1) -> void:
	var target_slot = slot if slot != -1 else current_slot
	var save_path = get_save_path(target_slot);

	# Create backup before saving
	create_backup(target_slot);

	# Save all cache data first
	save_data.persistence_cache = persistence_cache;
	save_data.timestamp = Time.get_unix_time_from_system()
	save_data.slot = target_slot;

	for system: String in save_systems:
		var save_object: SystemSaveData = save_systems[system];
		assert(save_object is SystemSaveData, "Incorrect object type registered for system " + system);
		save_data[system] = save_object.serialize()

	var save_file := FileAccess.open(save_path, FileAccess.WRITE);
	if save_file == null:
		print("FAILED TO SAVE");
		return;

	var data_string := JSON.stringify(save_data);
	save_file.store_string(data_string);
	save_file.close();


func load_game(slot: int = -1) -> bool:
	var target_slot = slot if slot != -1 else current_slot
	var save_path = get_save_path(target_slot);

	var save_file := FileAccess.open(save_path, FileAccess.READ);
	if save_file == null:
		print("NO SAVE FILE");
		return false;

	var json_string := save_file.get_as_text()
	save_file.close()

	save_data = JSON.parse_string(json_string);
	if save_data == null:
		print("CORRUPTED SAVE FILE");
		return try_restore_backup(target_slot);

	current_slot = target_slot
	persistence_cache = save_data.get("persistence_cache", {});

	for system in save_systems:
		if not save_data.has(system):
			# NO save data for this system
			continue
		var save_object: SystemSaveData = save_systems[system];
		var data = save_data[system];
		save_object.deserialize(data);

	return true;


func create_backup(slot: int) -> void:
	var save_path = get_save_path(slot);
	var backup_path = get_backup_path(slot);

	if FileAccess.file_exists(save_path):
		var dir = DirAccess.open(save_path.get_base_dir());
		dir.copy(save_path.get_file(), backup_path.get_file());


func try_restore_backup(slot: int) -> bool:
	var backup_path = get_backup_path(slot);
	var save_path = get_save_path(slot);

	if not FileAccess.file_exists(backup_path):
		return false;

	var dir = DirAccess.open("user://");
	if dir.copy(backup_path, save_path) == OK:
		print("Restored backup for slot ", slot);
		return load_game(slot);

	return false


func get_slot_info(slot: int) -> Dictionary:
	var save_path = get_save_path(slot);
	if not FileAccess.file_exists(save_path):
		return { "exists": false }

	var save_file := FileAccess.open(save_path, FileAccess.READ);
	if save_file == null:
		return { "exists": false }

	var json_string := save_file.get_as_text()
	save_file.close()

	var data = JSON.parse_string(json_string)
	if data == null:
		return { "exists": false }

	return {
		"exists": true,
		"timestamp": data.get("timestamp", 0),
		"slot": data.get("slot", slot),
	}


func get_most_recent_slot() -> int:
	var most_recent_slot = -1;
	var latest_timestamp = 0;

	for slot in range(max_slots):
		var slot_info = get_slot_info(slot)
		if slot_info.exists and slot_info.timestamp > latest_timestamp:
			latest_timestamp = slot_info.timestamp
			most_recent_slot = slot;

	return most_recent_slot;
