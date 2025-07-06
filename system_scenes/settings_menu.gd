class_name SettingsMenu
extends Control


# Graphics controls
@onready var fullscreen_checkbox: CheckBox = %FullscreenCheckbox
@onready var vsync_checkbox: CheckBox = %VsyncCheckbox
@onready var resolution_option: OptionButton = %ResolutionOption

# Audio controls
@onready var master_label: Label = %MasterLabel
@onready var master_slider: HSlider = %MasterSlider

@onready var music_label: Label = %MusicLabel
@onready var music_slider: HSlider = %MusicSlider

@onready var sfx_label: Label = %SfxLabel
@onready var sfx_slider: HSlider = %SfxSlider

@onready var ui_label: Label = %UILabel
@onready var ui_slider: HSlider = %UISlider

@onready var ambient_label: Label = %AmbientLabel
@onready var ambient_slider: HSlider = %AmbientSlider

# Navigation and buttons
@onready var back_button: Button = %BackButton
@onready var reset_button: Button = %ResetButton
@onready var apply_button: Button = %ApplyButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setup_ui()
	connect_signals()
	load_current_settings()
	# Settings autosave
	apply_button.visible = false;


func setup_ui() -> void:
	resolution_option.clear();
	for i in range(SettingsManager.available_resolutions.size()):
		var res_string = SettingsManager.get_resolution_string(i)
		resolution_option.add_item(res_string);

	master_slider.min_value = 0.0;
	master_slider.max_value = 1.0;
	master_slider.step = 0.1;

	music_slider.min_value = 0.0;
	music_slider.max_value = 1.0;
	music_slider.step = 0.1;

	sfx_slider.min_value = 0.0;
	sfx_slider.max_value = 1.0;
	sfx_slider.step = 0.1;

	ui_slider.min_value = 0.0;
	ui_slider.max_value = 1.0;
	ui_slider.step = 0.1;

	ambient_slider.min_value = 0.0;
	ambient_slider.max_value = 1.0;
	ambient_slider.step = 0.1;


func connect_signals() -> void:
	# Graphics
	fullscreen_checkbox.toggled.connect(_on_fullscreen_toggled);
	vsync_checkbox.toggled.connect(_on_vsync_toggled);
	resolution_option.item_selected.connect(_on_resolution_selected);

	# Audio
	master_slider.value_changed.connect(_on_master_volume_changed);
	music_slider.value_changed.connect(_on_music_volume_changed);
	sfx_slider.value_changed.connect(_on_sfx_volume_changed);
	ui_slider.value_changed.connect(_on_ui_volume_changed);
	ambient_slider.value_changed.connect(_on_ambient_volume_changed);

	# Navigation
	back_button.pressed.connect(_on_back_pressed);
	apply_button.pressed.connect(_on_apply_pressed);
	reset_button.pressed.connect(_on_reset_pressed);


func load_current_settings() -> void:
	# Graphics
	fullscreen_checkbox.button_pressed = SettingsManager.fullscreen;
	vsync_checkbox.button_pressed = SettingsManager.vsync;
	resolution_option.selected = SettingsManager.resolution_index;

	# Audio
	master_slider.value = SettingsManager.master_volume;
	music_slider.value = SettingsManager.music_volume;
	sfx_slider.value = SettingsManager.sfx_volume;

	update_volume_labels();


func update_volume_labels() -> void:
	master_label.text = "Master: " + str(int(master_slider.value * 100)) + "%";
	music_label.text = "Music: " + str(int(music_slider.value * 100)) + "%";
	sfx_label.text = "SFX: " + str(int(sfx_slider.value * 100)) + "%";
	ui_label.text = "UI: " + str(int(ui_slider.value * 100)) + "%";
	ambient_label.text = "Ambient: " + str(int(ambient_slider.value * 100)) + "%";


# Graphics callbacks
func _on_fullscreen_toggled(enabled: bool) -> void:
	SettingsManager.set_fullscreen(enabled);


func _on_vsync_toggled(enabled: bool) -> void:
	SettingsManager.set_vsync(enabled);


func _on_resolution_selected(index: int) -> void:
	SettingsManager.set_resolution(index);


# Audio callbacks
func _on_master_volume_changed(value: float) -> void:
	SettingsManager.set_master_volume(value);
	update_volume_labels()


func _on_music_volume_changed(value: float) -> void:
	SettingsManager.set_music_volume(value);
	update_volume_labels()


func _on_sfx_volume_changed(value: float) -> void:
	SettingsManager.set_sfx_volume(value);
	update_volume_labels();


func _on_ui_volume_changed(value: float) -> void:
	SettingsManager.set_ui_volume(value);
	update_volume_labels();


func _on_ambient_volume_changed(value: float) -> void:
	SettingsManager.set_ambient_volume(value);
	update_volume_labels();


# Navigation callbacks
func _on_back_pressed() -> void:
	MainInstances.game_runner._go_to_main_menu()


func _on_apply_pressed() -> void:
	SettingsManager.save_settings()


func _on_reset_pressed() -> void:
	# Show confirmation dialog first
	var dialog = ConfirmationDialog.new()
	dialog.dialog_text = "Reset all settings to defaults?"
	add_child(dialog)
	dialog.confirmed.connect(reset_to_defaults)
	dialog.popup_centered()


func reset_to_defaults() -> void:
	SettingsManager.fullscreen = false;
	SettingsManager.vsync = true;
	SettingsManager.resolution_index = 0;
	SettingsManager.master_volume = 1.0;
	SettingsManager.music_volume = 1.0;
	SettingsManager.sfx_volume = 1.0;

	SettingsManager.apply_all_settings();
	SettingsManager.save_settings();
	load_current_settings();
