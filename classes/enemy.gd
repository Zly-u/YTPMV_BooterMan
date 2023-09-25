class_name Enemy

extends CharacterBody2D

signal returned

var IGNORE_PLAYER: bool = false

@export var player: Player = null

@export var walls_map: TileMap = null
@export var path_map: TileMap = null

@export var tint: Color = Color.RED
@export var score: int = 200

@export var group_of_return_points: Node2D = null

@onready var AStar_grid: AStarGrid2D = AStarGrid2D.new()
var valid_positions: Array[Vector2i]

var follow_points: Array[Vector2i]

@onready var follow_spline: Curve2D = Curve2D.new()

@onready var anim = %enemy_anim

const speed: float = 60.0
const weak_speed: float = 40.0
const flee_speed: float = 120.0
var direction: Vector2 = Vector2.ZERO

var is_started: bool = false
@export var delay_before_active: float = 0.0
#====================================

func start():
	is_started = true
	
func stop():
	is_started = false

#====================================

var is_weak: bool = false
func make_weak():
	if delay_before_active > 0: return
	found_player_state = FOUND_STATE.sees_nothing
	is_weak = true
	%enemy_anim.self_modulate = Color.BLUE
	%enemy_anim.play("runnin")


func make_strong():
	found_player_state = FOUND_STATE.sees_nothing
	is_weak = false
	is_fleeing = false
	follow_spline.clear_points()
	follow_points.clear()
	%enemy_anim.self_modulate = tint
	%enemy_anim.play("default")


var pause_timer: float = 0.0
func pause(sec: float):
	pause_timer = sec
	

#====================================

var is_move_forced: bool = false
var forced_dir: Vector2 = Vector2.ZERO
func start_force_move_dir(dir: Vector2):
	found_player_state = FOUND_STATE.sees_nothing
	is_move_forced = true
	forced_dir = dir
	progress = 0
	follow_spline.clear_points()
	follow_points.clear()

func stop_force_move():
	is_move_forced = false
	forced_dir = Vector2.ZERO

#====================================

func init_path_grid() -> void:
	AStar_grid.size = walls_map.get_used_rect().size
	AStar_grid.cell_size = walls_map.tile_set.tile_size
	AStar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	AStar_grid.jumping_enabled = true
	AStar_grid.update()
	
	# Set which tile is wall and nothing
	for tile_x in range(AStar_grid.size.x):
		for tile_y in range(AStar_grid.size.y):
			var tile_pos: Vector2i = Vector2i(tile_x, tile_y)
			var is_wall: bool = walls_map.get_cell_source_id(0, tile_pos) != -1
			AStar_grid.set_point_solid(tile_pos, is_wall)
			if !is_wall:
				valid_positions.append(tile_pos)


func update_path(start_pos: Vector2, dest_point: Vector2 = Vector2(-1, -1)) -> Array[Vector2i]:
	var start_cell = path_map.local_to_map(start_pos)
	var end_cell   = path_map.local_to_map(dest_point)
	
	if start_cell == end_cell or \
		!AStar_grid.is_in_boundsv(start_cell) or \
		!AStar_grid.is_in_boundsv(end_cell):
		return []
	
	var path_ids = AStar_grid.get_id_path(start_cell, end_cell)
	
	return path_ids

#====================================================================================
enum FOUND_STATE {
	sees_nothing = 0,
	just_saw = 1,
	follows = 2
}
var found_player_state: FOUND_STATE = FOUND_STATE.sees_nothing
var initial_start_pos: Vector2
var prev_player_pos: Vector2 = Vector2(-1, -1)
var progress: float = 0.0
var prev_follow_points: Array = []
func follow_player():
	if found_player_state == FOUND_STATE.sees_nothing: return
	
	if found_player_state == FOUND_STATE.just_saw:
		found_player_state = FOUND_STATE.follows
		initial_start_pos = position
		progress = 0
	
	
	follow_points = update_path(initial_start_pos, player.position)
	
	if prev_follow_points.size() != 0:
		if follow_points != prev_follow_points:
			progress = 0
			initial_start_pos = position
			follow_points = update_path(initial_start_pos, player.position)
	
	prev_follow_points = follow_points

	follow_spline.clear_points()
	var is_first: bool = true
	for point in follow_points:
		if is_first:
			follow_spline.add_point(initial_start_pos)
			is_first = false
		else:
			var local_pos = path_map.map_to_local(point)
			follow_spline.add_point(local_pos)
	#---------------------------------------------------------------------------------
	
	var first_segment_len: float = follow_spline.get_point_position(0).distance_to(follow_spline.get_point_position(1))
	
	if !is_weak:
		progress += speed * get_physics_process_delta_time()
	else:
		progress += weak_speed * get_physics_process_delta_time()

	if follow_spline.point_count > 1: position = follow_spline.sample_baked(progress, false)
	
	if progress >= first_segment_len:
		initial_start_pos = position
		progress = 0



var pick_timing: float = 1.0 # in seconds
var search_rad: int = 10
var found_pos: Vector2 = Vector2(-1, 0)
func wander():
	if follow_spline.point_count <= 1 or prev_player_pos.x != -1:
		progress = 0
		if prev_player_pos.x == -1:
			valid_positions.shuffle()
			var cur_tile_pos: Vector2 = path_map.local_to_map(position)
			for valid_pos in valid_positions:
				if cur_tile_pos.distance_to(valid_pos) <= search_rad:
					found_pos = path_map.map_to_local(valid_pos)
					break
		
			follow_points = update_path(position, found_pos)
		else:
			follow_spline.clear_points()
			follow_points = update_path(position, prev_player_pos)
			prev_player_pos.x = -1
			
		
		var is_first: bool = true
		for point in follow_points:
			if is_first:
				follow_spline.add_point(position)
				is_first = false
			else:
				var local_pos = path_map.map_to_local(point)
				follow_spline.add_point(local_pos)
	#---------------------------------------------------------------------------------
	
	if !is_weak:
		progress += speed * get_physics_process_delta_time()
	else:
		progress += weak_speed * get_physics_process_delta_time()

	if follow_spline.point_count > 1: position = follow_spline.sample_baked(progress, false)
	
	if progress >= follow_spline.get_baked_length():
		follow_spline.clear_points()


var is_fleeing: bool = false
func make_flee():
	is_fleeing = true
	follow_points.clear()
	follow_spline.clear_points()
	found_player_state = FOUND_STATE.sees_nothing
	%enemy_anim.play("retreat")
	%enemy_anim.self_modulate = Color.WHITE


func flee():
	if follow_points.size() == 0:
		var flee_point: Vector2 = group_of_return_points.get_children().pick_random().position
		
		follow_points = update_path(position, flee_point)
		progress = 0
		
		for point in follow_points:
			var point_pos = path_map.map_to_local(point)
			follow_spline.add_point(point_pos)
	
	progress += flee_speed * get_physics_process_delta_time()

	if follow_spline.point_count > 1:
		position = follow_spline.sample_baked(progress, false)
	
	if progress >= follow_spline.get_baked_length():
		make_strong()
		returned.emit()
		progress = 0

#====================================================================================

var spl_pos: float = 0.0
var timer: float = 0.0
func _draw() -> void:
	if true: return
	if !OS.is_debug_build(): return
	
	timer += get_process_delta_time()
	spl_pos = 0.5+sin(timer)*0.5

	var line_points = []
	for point in follow_spline.point_count:
		line_points.append(follow_spline.get_point_position(point)-position)

	draw_polyline(line_points, %enemy_anim.self_modulate, 2)
	
	if found_player_state == FOUND_STATE.follows:
		draw_line(Vector2.ZERO, player.position-position, Color.RED, 1)
	
	var bezier_points = []
	if follow_spline.point_count != 0:
		var bezier_samples: float = 100.0
		for sample in bezier_samples:
			bezier_points.append(follow_spline.samplef(follow_spline.point_count*(sample/bezier_samples))-position)
		draw_polyline(bezier_points, Color.RED, 3)
		
#		draw_circle(follow_spline.samplef(spl_pos*follow_spline.point_count)-position, 2, Color.ORANGE)
#		draw_circle(follow_spline.sample(0, spl_pos)-position, 2, Color.DARK_KHAKI)
	
#	for val_point in valid_positions:
#		var rec = Rect2(path_map.map_to_local(val_point)-position-Vector2(4, 4), Vector2(8, 8))
#		draw_rect(rec, Color.RED)


func _ready():
	%enemy_anim.self_modulate = tint
	%enemy_anim.play("default")
	init_path_grid()



func _process(delta: float) -> void:
	# Gates
	
	if !is_started: return
	
	if delay_before_active > 0:
		delay_before_active -= delta
		if pause_timer > 0:
			pause_timer -= delta
		return
	
	if pause_timer > 0:
		pause_timer -= delta
		return
	
	# States and RayCast
	
	if !IGNORE_PLAYER:
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(position, player.position, 1)
		var result = space_state.intersect_ray(query)
		
		if result and result.collider is Player:
			if found_player_state == FOUND_STATE.sees_nothing:
				found_player_state = FOUND_STATE.just_saw
		else:
			if found_player_state == FOUND_STATE.follows:
				found_player_state = FOUND_STATE.sees_nothing
				prev_player_pos = player.position
				
	# Movement
	if !is_fleeing:
		if !is_move_forced:
			if found_player_state == FOUND_STATE.sees_nothing or is_weak:
				wander()
			else:
				follow_player()
		else:
			position += forced_dir * speed * delta
	else:
		found_player_state = FOUND_STATE.sees_nothing
		flee()
	
	queue_redraw()
