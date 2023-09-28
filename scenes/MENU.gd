extends Control

@export var game_scene: PackedScene = null
@export var credits_scene: PackedScene = null
@export var controls_scene: PackedScene = null

@export var angle_dir: float = 0
@export var field_offset_speed: float = 0

func _ready() -> void:
	%AnimatedSprite2D2.play("default")
	var g_MenuAmbient = get_tree().get_root().get_node("MenuAmbient")
	if !g_MenuAmbient.is_playing():
		g_MenuAmbient.start_anim()


func _process(delta: float) -> void:
	var dir: Vector2 = Vector2(1, 0).rotated(deg_to_rad(angle_dir))
#	%BgField.position.x = fmod(%BgField.position.x + dir.x * delta, 1.0)
#	%BgField.position.y = fmod(%BgField.position.y + dir.y * delta, 1.0)
	%BgField.region_rect.position -= dir * field_offset_speed * delta
#
#	print(%BgField.position)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)

func _on_button_credits_pressed() -> void:
	get_tree().change_scene_to_packed(credits_scene)

func _on_button_controls_pressed() -> void:
	get_tree().change_scene_to_packed(controls_scene)
