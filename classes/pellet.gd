@tool
class_name Pellet

extends StaticBody2D

@onready var sprite = %Sprite2D

@export var image: Texture2D = null:
	set(tex):
		image = tex
		
		
@export var points: int = 10
@export var isSpecial: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite.set_texture(image)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
