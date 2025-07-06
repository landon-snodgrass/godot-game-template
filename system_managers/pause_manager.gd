extends Node


# NOTE: possibility to future overlay types.
enum OVERLAY_TYPE {
	None,
	DarkenedBackground,
}

# Config
@export var pause_input_action: String = "ui_cancel";
#@export var auto_pause_on_focus_lost: bool = true;
@export var pause_audio: bool = true;
@export var pause_tree: bool = true;
@export var pause_overlay_type: OVERLAY_TYPE = OVERLAY_TYPE.None;
@export_file("*.tscn") var pause_menu_scene: String;

signal paused;
signal unpaused;

# State
var is_paused: bool = false;
var can_pause: bool = true;

# Instances
var current_menu_instance: Node;
var pause_menu_packed_scene: PackedScene;
var overlay: ColorRect;


func _ready() -> void:
	setup_overlay();
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu_packed_scene = load(pause_menu_scene)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(pause_input_action) and can_pause:
		toggle_pause();

func setup_overlay() -> void:
	if pause_overlay_type != OVERLAY_TYPE.None:
		overlay = ColorRect.new();
		if pause_overlay_type == OVERLAY_TYPE.DarkenedBackground:
			overlay.color = Color(0, 0, 0, 0.5);
		else:
			overlay.color = Color.TRANSPARENT;
		overlay.mouse_filter = Control.MOUSE_FILTER_STOP;
		overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);


func toggle_pause() -> void:
	if is_paused:
		unpause_game();
	else:
		pause_game();


func pause_game() -> void:
	if is_paused or not can_pause:
		return;

	is_paused = true;

	if pause_tree:
		get_tree().paused = true;

	if pause_audio:
		AudioManager.pause_music()

	show_pause_menu();
	paused.emit();


func unpause_game() -> void:
	if not is_paused:
		return;

	is_paused = false;

	if pause_tree:
		get_tree().paused = false;

	if pause_audio:
		AudioManager.resume_music();

	hide_pause_menu();
	unpaused.emit();


func show_pause_menu() -> void:
	if overlay:
		get_tree().current_scene.add_child(overlay);

	if pause_menu_packed_scene:
		current_menu_instance = pause_menu_packed_scene.instantiate()
		current_menu_instance.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
		get_tree().current_scene.add_child(current_menu_instance);


func hide_pause_menu() -> void:
	if overlay and overlay.get_parent():
		overlay.get_parent().remove_child(overlay);

	if current_menu_instance:
		current_menu_instance.queue_free()
