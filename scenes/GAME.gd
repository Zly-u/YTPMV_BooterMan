extends Node2D

@export var game_sounds: Dictionary = {
	start 				= preload("res://sounds/orig_mp3/game_start.mp3"),
	siren 				= preload("res://sounds/orig_mp3/siren_1.mp3"),
	win 				= preload("res://sounds/orig_mp3/intermission.mp3"),
	power_pellet_mode 	= preload("res://sounds/orig_mp3/power_pellet.mp3"),
	ghost_retreat 		= preload("res://sounds/orig_mp3/retreating.mp3")
}

@onready var player: Player = %Player

var score = 0
var isGameStarted: bool = false
var didWin: bool = false

var power_pill_time: float = 7.0
var cur_power_pill_timer: float = 0.0

func add_score(new_add_score: int):
	score += new_add_score
	%SCORE.text = "%04d" % score

func set_score(new_score: int):
	score = new_score
	%SCORE.text = "%04d" % score

func set_best_score(best_score: int):
	%BEST_SCORE.text = "%04d" % best_score

func _ready() -> void:
	var g_MenuAmbient = get_tree().get_root().get_node("MenuAmbient")
	if g_MenuAmbient: g_MenuAmbient.stop()
	
#	get_tree().set_debug_collisions_hint(true)
	
	if !OS.is_debug_build():
		for debug_element in [%walls, %debug]:
			debug_element.visible = false
	
	set_best_score(Global.load_score())
	set_score(Global.get_carry_score())
	
	if !Global.has_restarted:
		%GameAudio.stream = game_sounds.start
		%GameAudio.play()
		%AnimationPlayer.play("READY")
		%READY.visible = true
	else:
		start_game()
	
	# Collision Generation for player
#	var walls_tiles_size: Vector2i = %walls.get_used_rect().size
#	var tile_coll: RectangleShape2D = RectangleShape2D.new()
#	tile_coll.size = Vector2(8, 8)
#	for wx in walls_tiles_size.x:
#		for wy in walls_tiles_size.y:
#			var pos: Vector2i = Vector2i(wx, wy)
#			if %walls.get_cell_source_id(0, pos) == 1:
#				var coll: CollisionShape2D = CollisionShape2D.new()
#				coll.shape = tile_coll
#				coll.position = Vector2(8 * wx+4, 8 * wy+4)
#				%walls_coll.add_child(coll)
				
				
	# DEBUG CODE
#	player.start()
#	for enemy in $Enemies.get_children():
#		enemy.start()
#	%GameAudio.stream = siren
#	%GameAudio.play()
#	isGameStarted = true
#	%AnimationPlayer.stop()
#	%READY.visible = false


#func _draw() -> void:
#	for wall in %walls_coll.get_children():
#		var rect: Rect2 = Rect2(wall.position, Vector2(8, 8))
#		draw_rect(rect, Color.RED)


var timer: float = 0
func _process(delta: float) -> void:
#	queue_redraw()
	
	# Winning
	if didWin:
		timer += delta
		player.scale = Vector2(sin(timer*3)*1.5, cos(timer*3)*1.5)
		return

	# Start skip
	if Input.is_action_pressed("back"):
		get_tree().change_scene_to_file("res://scenes/MENU.tscn")

	# Start skip
	if player.just_started and not isGameStarted:
		if Input.is_action_pressed("skip"):
			start_game()
	
	if Input.is_action_pressed("restart"):
		Global.restart(get_tree())
	
	if player.is_dead: return
	
	# Power Pill mode
	if cur_power_pill_timer > 0 and player.pause_timer <= 0:
		cur_power_pill_timer -= delta
		if cur_power_pill_timer <= 0:
			%GameAudio.stream = game_sounds.siren
			%GameAudio.play()
			
			for enemy in $Enemies.get_children():
				enemy.make_strong()
	
	if cur_power_pill_timer > 0 and cur_power_pill_timer < 2:
		for enemy in $Enemies.get_children():
			if !enemy.is_weak: continue
			enemy.anim.self_modulate = Color.BLUE if enemy.anim.frame == 1 else Color.WHITE


func _on_right_side_body_entered(body: Node2D) -> void:
	body.position.x = $TeleportPoint_L.position.x


func _on_left_side_body_entered(body: Node2D) -> void:
	body.position.x = $TeleportPoint_R.position.x


func _on_player_ate_buter(_add_score: int, is_power_pill: bool) -> void:
	score += _add_score
	%SCORE.text = "%04d" % score
	
	if is_power_pill:
		%GameAudio.stream = game_sounds.power_pellet_mode
		%GameAudio.play()
		
		for enemy in $Enemies.get_children():
			enemy.make_weak()
		cur_power_pill_timer = power_pill_time
	
	if $Pellets.get_children().size() == 1:
		didWin = true
		Global.save(score)
		Global.set_carry_score(score)
		
		for enemy in $Enemies.get_children():
			enemy.stop()
		%GameAudio.stream = game_sounds.win
		%GameAudio.play()
		player.stop()
	
	


func start_game() -> void:
	player.start()
	for enemy in $Enemies.get_children():
		enemy.start()
		enemy.connect("returned", _on_ghost_returned)

	
	%GameAudio.stream = game_sounds.siren
	%GameAudio.play()
	isGameStarted = true
	
	%AnimationPlayer.stop()
	%READY.visible = false
	%SKIP.visible = false
	# Debug, deleting most of the buters in order to test win conditions
#	if OS.is_debug_build():
#		var child_count = 0
#		for child in $Pellets.get_children():
#			child_count += 1
#			child.queue_free()
#			if child_count > $Pellets.get_children().size()-10:
#				break

func _on_game_audio_finished() -> void:
	if player.just_started and not isGameStarted:
		start_game()
		
	
	if didWin:
		get_tree().reload_current_scene()




func _on_enemy_enable_force_move_l_body_entered(body: Enemy) -> void:
	if not body is Enemy: return
	if body.is_move_forced: return
	
	body.start_force_move_dir(Vector2(-1, 0))


func _on_enemy_enable_force_move_r_body_entered(body: Enemy) -> void:
	if not body is Enemy: return
	if body.is_move_forced: return
	
	body.start_force_move_dir(Vector2(1, 0))


func _on_enemy_disable_force_move_l_body_entered(body: Enemy) -> void:
	if not body is Enemy: return
	
	body.stop_force_move()


func _on_enemy_disable_force_move_r_body_entered(body: Enemy) -> void:
	if not body is Enemy: return
	
	body.stop_force_move()


func _on_player_died() -> void:
	Global.clear_carry_score()
	
	for enemy in $Enemies.get_children():
		enemy.stop()
		enemy.visible = false
	
	%GameAudio.stop()

#=========================================================

var num_of_returning_ghosts: int = 0
func _on_player_ate_ghost(_add_score) -> void:
	%Player.pause(0.7)
	for enemy in $Enemies.get_children():
		enemy.pause(0.7)
	
	score += _add_score
	%SCORE.text = "%04d" % score
	
	num_of_returning_ghosts += 1
	
	if %GameAudio.stream != game_sounds.ghost_retreat:
		%GameAudio.stream = game_sounds.ghost_retreat
		%GameAudio.play()

func _on_ghost_returned() -> void:
	num_of_returning_ghosts -= 1
	if num_of_returning_ghosts == 0:
		%GameAudio.stream = game_sounds.power_pellet_mode
		%GameAudio.play()
	
	var found_weak_one: bool = false
	for enemy in $Enemies.get_children():
		if enemy.is_weak:
			found_weak_one = true
			break
	
	if !found_weak_one:
		cur_power_pill_timer = 0.0
		%GameAudio.stream = game_sounds.siren
		%GameAudio.play()
#=========================================================
