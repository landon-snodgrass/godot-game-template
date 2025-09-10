class_name Stasher
extends RefCounted


var target: set = set_target;
var starting_position: Vector2;


func set_target(value: Node2D) -> Stasher:
	target = value;
	if target is not Node2D: return self;
	starting_position = target.global_position;
	return self;


func get_id() -> String:
	var game_runner := target.get_tree().current_scene as GameRunner;
	assert(game_runner, "Can't get ID of object not in Game");
	var id: String = (
		target.scene_file_path
		+ " at " + str(starting_position.round())
		+ " in " + game_runner.current_scene.scene_file_path
	);
	return id;


func stash_property(property: String, value: Variant) -> void:
	var id := get_id();
	if not SaveManager.persistence_cache.has(id):
		SaveManager.persistence_cache[id] = {};
	SaveManager.persistence_cache[id][property] = value;


func stash_properties(properties: Dictionary) -> void:
	var id := get_id();
	if not SaveManager.persistence_cache.has(id):
		SaveManager.persistence_cache[id] = {};
	for prop in properties:
		SaveManager.persistence_cache[id][prop] = properties[prop];


func retrieve_property(property: String, default_value: Variant = null) -> Variant:
	var id := get_id();
	if not SaveManager.persistence_cache.has(id): return default_value;
	if not SaveManager.persistence_cache[id].has(property): return default_value;
	var result = SaveManager.persistence_cache[id][property];
	if not result:
		return default_value;
	return result;
