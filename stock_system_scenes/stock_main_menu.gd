class_name MainMenu
extends Control


@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueGameButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton


@export_file("*.tscn") var settings_scene: String


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Check if save file exists
	var most_recent_slot = SaveManager.get_most_recent_slot()
	if most_recent_slot == -1:
		continue_button.disabled = true;
	else:
		continue_button.disabled = false;


func _on_new_game_pressed() -> void:
	SaveManager.clear_save_data();
	start_new_game()

func _on_continue_pressed() -> void:
	SaveManager.load_game()
	start_loaded_game()

func _on_settings_pressed() -> void:
	await Transitions.fade_out_to_black()
	await MainInstances.game_runner.change_scene(settings_scene)
	await Transitions.fade_in_from_black()

func _on_quit_pressed() -> void:
	get_tree().quit()

# Override these in your specific game
func start_new_game() -> void:
	push_error("start_new_game() must be implemented")

func start_loaded_game() -> void:
	push_error("start_loaded_game() must be implemented")
