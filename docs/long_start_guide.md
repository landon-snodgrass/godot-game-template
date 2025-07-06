# Long start Guide
This guide is here to help you actually get your game running and use the template. The first part is just the bare minimum to get gameplay in the game
and the second part is a list of suggestions to use the template to it's fullest.

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
    