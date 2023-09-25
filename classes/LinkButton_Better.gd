class_name LinkButton_Better

extends LinkButton

signal link_pressed(_self: LinkButton_Better)

@export var data: Dictionary = {}

func _ready() -> void:
	pressed.connect(_link_pressed_wrap)

func _link_pressed_wrap():
	link_pressed.emit(self)
