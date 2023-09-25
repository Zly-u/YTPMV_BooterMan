extends Control

@export var game_scene: PackedScene = null
@export var credits_scene: PackedScene = null
@export var controls_scene: PackedScene = null
@export var field_offset_speed = Vector2(0, 0)

func _ready() -> void:
	%AnimatedSprite2D2.play("default")
	var g_MenuAmbient: AudioStreamPlayer2D = get_tree().get_root().get_node("MenuAmbient")
	if !g_MenuAmbient.playing:
		g_MenuAmbient.play()

func _process(delta: float) -> void:
	%BgField.region_rect.position += field_offset_speed * delta

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)

func _on_button_credits_pressed() -> void:
	get_tree().change_scene_to_packed(credits_scene)

func _on_button_controls_pressed() -> void:
	get_tree().change_scene_to_packed(controls_scene)
