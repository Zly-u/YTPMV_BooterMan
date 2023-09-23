extends Node2D

@export var siren: AudioStream = null
@export var win: AudioStream = null

@onready var player = %Player

var score = 0
var isGameStarted: bool = false
var didWin: bool = false

var child_count = 0
func _ready() -> void:
	%GameAudio.stream = player.sounds.start
	%GameAudio.play()
	%AnimationPlayer.play("READY")
	%READY.visible = true

	# DEBUG CODE
	player.start()
	
	%GameAudio.stream = siren
	%GameAudio.play()
	isGameStarted = true
	
	%AnimationPlayer.stop()
	%READY.visible = false

var timer = 0
func _process(delta: float) -> void:
	if didWin:
		timer += delta
		player.scale = Vector2(sin(timer*3)*1.5, cos(timer*3)*1.5)


var came_from_side = 0
func _on_right_side_body_entered(body: Node2D) -> void:
	if came_from_side != 0: return
	
	came_from_side = 1
	body.position.x = get_viewport_rect().size.x-body.position.x


func _on_left_side_body_entered(body: Node2D) -> void:
	if came_from_side != 0: return
	
	came_from_side = -1
	body.position.x = get_viewport_rect().size.x - body.position.x


func _on_left_side_body_exited(body: Node2D) -> void:
	if came_from_side == 1:
		came_from_side = 0


func _on_right_side_body_exited(body: Node2D) -> void:
	if came_from_side == -1:
		came_from_side = 0


func _on_player_ate_buter(add_score: int) -> void:
	score += add_score
	%SCORE.text = "%04d" % score
	
	if $Pellets.get_children().size() == 1:
		didWin = true
		%GameAudio.stream = win
		%GameAudio.play()
		player.stop()


func _on_game_audio_finished() -> void:
	if player.just_started and not isGameStarted:
		player.start()
		
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
