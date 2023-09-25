class_name Player

extends CharacterBody2D

signal ate_buter(add_score: int, is_power_pill: bool)
signal ate_ghost(add_score: int)
signal died

const SPEED: float = 60.0

@export var sounds = {
	munch_1 = preload("res://sounds/orig_mp3/munch_1.mp3"),
	munch_2 = preload("res://sounds/orig_mp3/munch_2.mp3"),
	death_1 = preload("res://sounds/orig_mp3/death_1.mp3"),
	death_2 = preload("res://sounds/orig_mp3/death_2_full.mp3"),
	
	eat_ghost = preload("res://sounds/orig_mp3/eat_ghost.mp3"),
	eat_fruit = preload("res://sounds/orig_mp3/eat_fruit.mp3"),
}

var direction: Vector2
var movement: Vector2

var just_started = true
var is_dead = false
func start():
	just_started = false
	%player_anim.speed_scale = 1
	%player_anim.play("default")

func stop(speed_scl: float = 5):
	just_started = true
	
	%player_anim.speed_scale = speed_scl
	%player_anim.flip_h = false
	%player_anim.flip_v = false
	%player_anim.rotation = 0

var pause_timer: float = 0.0
func pause(sec: float):
	pause_timer = sec

func _process(delta: float) -> void:
	if pause_timer > 0:
		pause_timer -= delta
		return
	
	if is_dead and !%Audio.playing:
		if %player_anim.frame == 1:
			%Audio.stream = sounds.death_1
			%Audio.play()
	elif is_dead and %Audio.playing:
		if %player_anim.frame == 6:
			%Audio.stream = sounds.death_2
			%Audio.play()


func _physics_process(_delta: float) -> void:
	if just_started: return
	if pause_timer > 0: return
	
	
	if Input.get_axis("ui_left", "ui_right") != 0:
		direction.x = Input.get_axis("ui_left", "ui_right")
	elif Input.get_axis("ui_up", "ui_down") != 0:
		direction.y = Input.get_axis("ui_up", "ui_down")
		
	
	
	
	velocity = direction * SPEED
	
	if is_on_wall() and direction.x != 0:
		direction.x = 0
	if (is_on_ceiling() or is_on_floor()) and direction.y != 0:
		direction.y = 0
	
	move_and_slide()
	
	var norm_velocity = velocity.normalized()
	if norm_velocity.x > 0:
		%player_anim.flip_h = false
	if norm_velocity.x < 0:
		%player_anim.flip_h = true
		
	if norm_velocity.y > 0:
		%player_anim.rotation = 90
	if norm_velocity.y < 0:
		%player_anim.rotation = -90
	
	if norm_velocity.x != 0:
		%player_anim.rotation = 0
	if norm_velocity.y != 0:
		%player_anim.flip_h = false


func death():
	%player_anim.play("death")
	
	stop(1)
	died.emit()
	is_dead = true


var sound_num = 0
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Pellet:
		body.queue_free()

		%Audio.stream = sounds["munch_" + str(sound_num+1)]
		%Audio.play()
		sound_num = (sound_num + 1) % 2
		
		ate_buter.emit(body.points, body.is_power)
		
	elif body.name == "Enemy_coll":
		var enemy: Enemy = body.get_parent()
		if enemy.is_fleeing: return
		if enemy.IGNORE_PLAYER: return
		
		if !enemy.is_weak:
			death()
		else:
			enemy.make_flee()
			ate_ghost.emit(enemy.score)
			
			%Audio.stream = sounds.eat_ghost
			%Audio.play()



func _on_player_anim_animation_finished() -> void:
	match(%player_anim.animation):
		"death":
			get_tree().reload_current_scene()
		_:
			pass
