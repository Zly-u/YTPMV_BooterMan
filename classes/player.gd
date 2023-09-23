class_name Player

extends CharacterBody2D

signal ate_buter(add_score: int)

const SPEED = 80.0

@export var sounds = {
	start   = preload("res://sounds/orig/game_start.wav"),
	
	munch_1 = preload("res://sounds/orig/munch_1.wav"),
	munch_2 = preload("res://sounds/orig/munch_2.wav"),
	death_1 = preload("res://sounds/orig/death_1.wav"),
	death_2 = preload("res://sounds/orig/death_2.wav"),
}

var direction: Vector2

var just_started = true

func start():
	just_started = false
	%player_anim.speed_scale = 1
	%player_anim.play("default")

func stop():
	just_started = true
	%player_anim.speed_scale = 5

func _physics_process(delta: float) -> void:
	if just_started: return
	
	if direction.x == 0:
		direction.x = Input.get_axis("ui_left", "ui_right")
	if direction.y == 0:
		if is_on_floor():
			position.y -= 1
		if is_on_ceiling():
			position.y += 1
		direction.y = Input.get_axis("ui_up", "ui_down")


	if is_on_wall() and direction.x != 0:
		position.x -= sign(direction.x)
		direction.x = 0
	if (is_on_ceiling() or is_on_floor()) and direction.y != 0:
		position.y -= sign(direction.y)
		direction.y = 0
		
	
	if direction.x > 0:
		%player_anim.flip_h = false
	if direction.x < 0:
		%player_anim.flip_h = true
		
	if direction.y > 0:
		%player_anim.rotation = 90
	if direction.y < 0:
		%player_anim.rotation = -90
	
	if direction.x != 0:
		%player_anim.rotation = 0
	if direction.y != 0:
		%player_anim.flip_h = false
	
	velocity = direction * SPEED
	move_and_slide()


func death():
	get_tree().reload_current_scene()


var sound_num = 0
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Pellet:
		body.queue_free()

		%Audio.stream = sounds["munch_" + str(sound_num+1)]
		%Audio.play()
		sound_num = (sound_num + 1) % 2
		
		ate_buter.emit(body.points)
	elif body.name == "Enemy_coll":
		death()
	else:
		pass
	
	
