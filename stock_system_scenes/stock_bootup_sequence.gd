class_name BootupSequence
extends Control


@export var logo_textures: Array[Texture] = [];


@onready var boot_logos: TextureRect = %BootLogos
@onready var timer: Timer = %Timer


signal bootup_sequence_finished;


func _ready() -> void:
	if logo_textures.size() == 0:
		skip_sequence();
	else:
		start_sequence();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		skip_sequence();


func start_sequence() -> void:
	boot_logos.modulate = Color(1, 1, 1, 0);
	for texture: Texture in logo_textures:
		if boot_logos.texture:
			var fade_out_tween: Tween = create_tween()
			fade_out_tween.tween_property(boot_logos, "modulate", Color(1, 1, 1, 0), 0.5);
			fade_out_tween.play();
			await fade_out_tween.finished;
		boot_logos.texture = texture;
		var fade_in_tween: Tween = create_tween();
		fade_in_tween.tween_property(boot_logos, "modulate", Color(1, 1, 1, 1), 0.5);
		fade_in_tween.play();
		await fade_in_tween.finished;
		timer.start()
		await timer.timeout;
	if boot_logos.texture:
		var fade_out_tween: Tween = create_tween()
		fade_out_tween.tween_property(boot_logos, "modulate", Color(1, 1, 1, 0), 0.5);
		fade_out_tween.play();
		await fade_out_tween.finished;
	bootup_sequence_finished.emit();


func skip_sequence():
	bootup_sequence_finished.emit();
