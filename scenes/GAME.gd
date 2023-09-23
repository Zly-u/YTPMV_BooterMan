extends Node2D

@export var siren: AudioStream = null
@export var win: AudioStream = null

@onready var player = %Player

var score = 0
var isGameStarted: bool = false
var didWin: bool = false

var child_count = 0
func _ready() -> void:
#	get_tree().set_debug_collisions_hint(true)
	
	%GameAudio.stream = player.sounds.start
	%GameAudio.play()
	%AnimationPlayer.play("READY")
	%READY.visible = true
	
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
	
	if didWin:
		timer += delta
		player.scale = Vector2(sin(timer*3)*1.5, cos(timer*3)*1.5)


func _on_right_side_body_entered(body: Node2D) -> void:
	body.position.x = $TeleportPoint_L.position.x


func _on_left_side_body_entered(body: Node2D) -> void:
	body.position.x = $TeleportPoint_R.position.x


func _on_player_ate_buter(add_score: int) -> void:
	score += add_score
	%SCORE.text = "%04d" % score
	
	if $Pellets.get_children().size() == 1:
		didWin = true
		
		for enemy in $Enemies.get_children():
			enemy.stop()
		%GameAudio.stream = win
		%GameAudio.play()
		player.stop()


func _on_game_audio_finished() -> void:
	if player.just_started and not isGameStarted:
		player.start()
		for enemy in $Enemies.get_children():
			enemy.start()
		
		%GameAudio.stream = siren
		%GameAudio.play()
		isGameStarted = true
		
		%AnimationPlayer.stop()
		%READY.visible = false
		
		# Debug, deleting most of the buters in order to test win conditions
#		for child in $Pellets.get_children():
#			child_count += 1
#			child.queue_free()
#			if child_count > $Pellets.get_children().size()-10:
#				break
	
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
