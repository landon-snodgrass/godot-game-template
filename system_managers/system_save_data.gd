class_name SystemSaveData
extends RefCounted


var system: Node;


func _init(target_system: Node, system_key: String) -> void:
	system = target_system;
	SaveManager.register_system(system_key, self);


func serialize() -> Dictionary:
	push_error("serialize() must be implemented")
	return {};


func deserialize(data: Dictionary) -> void:
	push_error("deserialize() must be implemented");
