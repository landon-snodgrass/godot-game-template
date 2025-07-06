# Landon's Godot Game Template
This a game template for Godot 4.4 that takes care of the boring stuff like menus, saving/loading, pausing, settings so that you can just focus
on making the game portion of your game. Ideal for game jams or as a basis for build a production game.

Since this is mostly for my own personal use, I'm not attempting to make it flexible or unopinionated. I want to follow Godot's conventions
as best as possible but the certain aspects of the template are very opinionated.

## What it does
- Handles saving/loading with an API to implement custom save data
- Handles the main menu and settings menu (they can be customized for look and feel)
    - The settings are saved automatically into a config file
- Handles music, SFX, and ambient sounds with an extendable API
- Handles pausing with a fairly flexible pause manager
- Handles scene transitions with fade in/out

## What is doesn't do
- Handle pretty much any gameplay logic.
This is truly meant to just be a template that any game can be built on top of. Ideally, I'll be creating more bespoke frameworks in the future
that include more gameplay logic, but this template is not that.

# Quick start
- Download this repository and import it into Godot.
- Ideally, most everything should already be set up but just in case, here are the prerequisites for it to work
    - Configure the autoloads - These resources need to be autoloaded (**important** the Transitions and Pause Manager are `.tscn` files that need 
    to be autoloaded, not just the script.)
    - - `transitions.tscn`
    - - `pause_manager.tscn`
    - - `save_manager.gd`
    - - `audio_manager.gd`
    - - `settings_manager.gd`
    - - `main_instances.gd`
    - Set `game_runner.tscn` as the Main Scene in the project settings (Project Settings -> General -> Application -> Run -> Main Scene)
    - Open the `game_runner.tscn` and set the two "Start Up Scenes" export variables (if they're not already set):
    - - Bootup Sequence: `res://stock_system_scenes/stock_bootup_sequence.tscn`
    - - Main Menu Scene: `res://stock_system_scenes/stock_main_menu.tscn`
- Once the game starts with no errors and you see the menu. Follow the [long start guide](docs/long_start_guide.md) to get an actual game running.

# Systems
Docs for the various systems in order of importance for getting your game off the ground. I recommend reading these in order the first time 
then coming back to reference them as needed.
- [Game Runner](docs/systems/game_runner.md) - The main scene of the game and the main orchestrator of everything
- [Save Manager](docs/systemssave_manager.md) - The functionality for saving and loading your game along with entity persistence
- [Main Instances](docs/systemsmain_instances.md) - A singleton for storing references for important instances needed across the game
- [Pause Manager](docs/systemspause_manager.md) - The manager for pausing your game
- [Transitions](docs/systemstransitions.md) - The singleton that handles screen fade ins and outs
- [Audio Manager](docs/systemsaudio_manager.md) - The manager for playing music, ambiences, and SFX
- [Settings Manager](docs/systemssettings_manager.md) - The manager for handling the settings of your game