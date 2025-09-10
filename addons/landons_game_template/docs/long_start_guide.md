# Long start Guide
This guide is here to help you actually get your game running and use the template. The first part is just the bare minimum to get gameplay in the game
and the second part is a list of suggestions to use the template to it's fullest.

> **NOTE:** If the project won't run and you're getting errors, checkout the "Quick Start" portion of the [README](../README.md) to get the project setup first.

## Bare minimum
Basically, you'll need to implement the `start_new_game()` function in the `stock_system_scenes/stock_main_menu.tscn` node. This could look something like
this:
```
# Further up in the file
@export_file("*.tscn") var level_one_scene;

#...

func start_new_game() -> void:
    await Transitions.fade_out_to_black();
    var scene = await MainInstances.game_runner.change_scene(level_one_scene);
    await Transitions.fade_in_from_black();
    scene.do_something_to_level_one();
```

This will allow you to start the game on level one. However, the `start_loaded_game()` function is still not implemented. That's because there are a few
different ways you might need to start a loaded game. Two common options *could* look like this:

1. You character always starts in the same scene a la Stardew Valley (you always load into your house). This is the simplest option.
```
# Futher up in the file
@export_file("*.tscn") var player_house_scene;

#...

func start_loaded_game() -> void:
    # NOTE: The game will already be loaded from disk
    await Transitions.fade_out_to_black();
    var scene = await MainInstances.game_runner.change_scene(player_house_scene)
    scene.update_player_house_state() # This function would pull from the SaveManager.persistence_cache or a saved system
    await Transitions.fade_in_from_black();
```
What this would do would be to load a static scene, update the state of that scene based off of the data that was loaded from disk.

2. You save the scene the player was in into the save data. This would be the case if the player could save from anywhere in the world or
at save positions with a specific location.

```
func start_loaded_game() -> void:
    # You would have to implement saving the scene where the player saved and you'd probably want to save it as a scene path
    var scene_path_to_load_in_to: String = SaveManager.persistence_cache.saved_location_scene # NOTE: should be a *scene path* 
    await Transitions.fade_out_to_black();
    var scene = await MainInstances.game_runner.change_scene(scene_path_to_load_in_to); # NOTE: scene is an instanced scene
    scene.update_location_state() # if you want to make sure stuff is updated
    await Transitions.fade_in_from_black();
```
This would do something very similar but would pull the scene to load from the saved data instead of just a fixed scene.

> **IMPORTANT NOTE REGARDING CHANGING SCENES:** While the `game_runner.change_scene` function happens in a matter of a frame or two (basically instantly) the transitions have a default time of 0.5 seconds which means you **might want to consider pausing input** during these transitions. Depending on your game, you may want to pause the tree either manually or by using the Pause Manager or you may just want to pause input on the player and then unpause it once the game has faded back in. Just a heads up. 
    
## Save Manager
This is probably the next most important thing to learn to make your game work. A more detailed guide on the Save Manager is [here](../docs/systems/save_manager.md). This
will just be a brief overview to get you up and running as quickly as possible.

The Save System is a slot based system meaning that each slot is a single play through with one loadable save. Think Stardew Valley where you just load your slot rather than
something like Baldur's Gate where there are many slots and you can load an old save.

> Note: This will be extended in the future to include a more flexible slot system where each slot can have multiple saves.

The Save Manager has two foundational parts: 
- **The persistence cache** - The system for individual entities to save they're data. For example, if you chop down a tree and it needs to stay in the chopped down state.
The persistence cache will work for both in-session persistence (you leave a level and come back and everything is still the same) and for writing the information to disk (you save the game, turn it off, then turn it back on and the tree is still chopped down).
- **The system save data** - This system is for more global save data like the player's inventory, player's stats, general game progression, etc. 

### How to use:

**Persistence Cachce:**

For object persistence you'll be using the `Stasher` class. This example I'll give will be for the tree example but this is a pretty flexible system that can be used for
a lot of different things.

``` 
class_name Tree
extends StaticBody2D

var stasher = Stasher.new().set_target(self);

func _ready():
    # Check if the tree has been chopped down
    if stasher.retrieve_property("is_chopped"):
        queue_free() # For simplicity's sake, we're freeing but you could just as easily set the state instead

# The function that runs when a tree is chopped down (assumingly after being hit with an axe or something)
func chop_down():
    # Save the property
    stasher.stash_property("is_chopped", true);
    queue_free();
```

The two key methods are the `stasher.retrieve_property` and the `stasher.stash_property` methods. The Stasher class will store a custom ID for this entity and then
retrieve the data based on that ID. 

> **Important Note:** The ID is based off of the Node's starting position in the scene so if this changes during development (for example you move an enemy around in the level) the persistence data won't work for that entity. Similarly, if you place to entities in the exact same position, it won't work correctly either. In the future, I want to create 
support for custom entity IDs for this reason but it's not done yet.

**System Save Data:**
For saving more global system data like an inventory or stats, you'll use the `SystemSaveData` class. This class should be extended for each system that needs data to be saved
and should implement the `serialize` and `deserialize` functions for whatever your system needs. Here's an example with a PlayerStats system:

```
# PlayerStatsSaveData.gd
# This is the class that extends the SystemSaveData not the Player Stats class itself

class_name PlayerStatsSaveData.gd
extends SystemSaveData

func serialize() -> Dictionary:
    return {
        "level": system.level,
        "experience": system.experience,
        "gold": system.gold,
    }

func deserialize(data: Dictionary) -> void:
    system.level = data.get("level", 1);
    system.experience = data.get("experience", 0);
    system.gold = data.get("gold", 0);
```

```
# PlayerStats.gd
# This would be the actual stats class

class_name PlayerStats
extends Node

var save_data: PlayerStatsSaveData

func _ready() -> void:
    save_data = PlayerStatsSaveData.new(self, "player_stats");
```

The SystemSaveData class automatically register with the Save Manager and handle saving the data to disk and has a
`system` variable that it'll automatically assign. The `_init` function needs a Node as it's first argument and then a unique key as it's second argument.

The Save Manager will call `serialize` on each registered system and save that data to disk under the ID provided. It will also call `deserialize` when the 
game is loaded.

**Highly Recommended:** The systems using this save system should be autoloads so they're always available. 

**Saving and Loading Operations:**
```
# Saves game into default slot
SaveManager.save_game()

# Load game from default slot
SaveManager.load_game()

# Save/load from various slots
SaveManager.save_game(1) # Save to slot 1
SaveManager.load_game(2) # Load from slot 2

# Helpers for slot based saving
var slot_info = SaveManager.get_slot_info(3) # returns basic info about slot
if slot_info.exists:
    print("Save found from: ", slot_info.timestamp)

var most_recent_slot = SaveManager.get_most_recent_slot();
# You'll probably use this to implement a "continue" button

# Deletes the slot
SaveManage.delete_slot(4);
```

> **Note:** I plan to implement better slot info functionality since the info you get is sparsed currently, it just gives you a timestamp, the slot number, and if it exists. 
It would be nice to have that be extensible so it could return custom data based on your game like "Player Name" or "Percent Complete".

**Some additional things:**
The paths for the save file are configured in the `system_managers/save_manager.gd` file here:
```
const TEST_PATH := "res://game_save";
const PRODUCTION_PATH := "user://game_save";

var base_save_path := TEST_PATH;
```

The final value of the path takes the slot into account and will look more like `user://game_save_slot_2.save`

Feel free to chamge those as you see fit.

The system also stores a backup at each save and will attempt to load this backup when call the `load_game` function if the current save is corrupted.

## Sound and Music
The Audio Manager is pretty simple, you can play music, ambient sounds, and non positional sounds (for positional sounds see below). The general architecture is that one music track can be playing at once, whereas multiple ambient sounds can be playing and multiple sfx can be playing. The SFX are divided into standard SFX and UI SFX, this is in case you have some sort of environmental effect (echo for a cave or something) on the SFX and you don't want the UI sounds affected. 

The basic functions are:
- `play_music` - plays an audio stream with optional fade in and sets it as the music track
- `stop_music` - stops the music track with optional fade out
- `pause_music` - pauses current music track
- `resume_music` - resumes current music track
- `play_ambience` - adds an ambience track to the sound pool and returns the ID of that ambient track
- `stop_ambience` - stops the ambient track given the ID
- `play_sfx` - plays standard SFX
- `play_ui_sfx` - plays UI SFX

Another kind of random and possibly helpful function is `play_music_intro_loop` this takes two AudioStreams and plays the first one once then the second one as a loop. This is in case you have a track that has an intro that you don't want to be in the loop.

**Positional Sounds**
For positional sounds you can either use the built in AudioStreamPlayer2D node, just remember to set the bus to SFX or you can use the custom node `SpatialAudioSource` (just add a new node like normal and select this from the list) which is a simple wrapper for an AudioStreamPlayer2D that sets the bus for you for convenience. 


## Next steps:
The next steps would be customizing the "stock scenes" in the `stock_system_scenes/` directory and to read through the rest of the docs.