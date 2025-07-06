class_name GameRunner
extends Node


@export_group("Start up scenes")
@export_file("*.tscn") var bootup_sequence_scene;
@export_file("*.tscn") var main_menu_scene;


var current_scene: Node;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MainInstances.game_runner = self;

	assert(bootup_sequence_scene, "Bootup Sequence Scene is required in the Game Runner");
	assert(main_menu_scene, "Main Menu Scene is required in the Game Runner");

	var bootup_sequence_instance: BootupSequence = load(bootup_sequence_scene).instantiate();

	add_child(bootup_sequence_instance);
	current_scene = bootup_sequence_instance;
	bootup_sequence_instance.bootup_sequence_finished.connect(_go_to_main_menu)


func change_scene(scene_path: String) -> Node:
	current_scene.queue_free();
	await current_scene.tree_exited;
	var new_scene: Node = load(scene_path).instantiate();
	current_scene = new_scene;
	add_child(current_scene);
	return current_scene;


func _go_to_main_menu() -> void:
	await Transitions.fade_out_to_black();
	var main_menu = await change_scene(main_menu_scene);
	await Transitions.fade_in_from_black();
