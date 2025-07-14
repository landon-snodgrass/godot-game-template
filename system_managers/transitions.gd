extends CanvasLayer


@onready var color_rect: ColorRect = %ColorRect


var current_tween: Tween;


func _ready() -> void:
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE;
	color_rect.color = Color("black", 0.0)


## Fades the screen out to black with an optional [duration] property. Returns
## a signal that can be awaited.
func fade_out_to_black(duration: float = 0.5) -> Signal:
	if current_tween:
		current_tween.kill();
	# Can't pause during transitions
	var can_pause = PauseManager.can_pause;
	PauseManager.can_pause = false;
	current_tween = get_tree().create_tween()
	current_tween.tween_property(color_rect, "color", Color.BLACK, duration);
	current_tween.play();
	# Turn pausing back to whatver it was before
	current_tween.tween_callback(func(): PauseManager.can_pause = can_pause)
	return current_tween.finished;


## Fades the screen in from black with an option [duration] property. Returns
## a signal that can be awaited.
func fade_in_from_black(duration: float = 0.5) -> Signal:
	if current_tween:
		current_tween.kill();
	# Can't pause during transitions
	var can_pause = PauseManager.can_pause;
	PauseManager.can_pause = false;
	current_tween = get_tree().create_tween();
	current_tween.tween_property(color_rect, "color", Color("black", 0.0), duration);
	current_tween.play();
	current_tween.tween_callback(func(): PauseManager.can_pause = can_pause)
	return current_tween.finished;
