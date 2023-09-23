class_name Enemy

extends CharacterBody2D

@export var player: Player = null

@export var walls_map: TileMap = null
@export var path_map: TileMap = null

@export var tint: Color = Color.RED

@onready var AStar_grid: AStarGrid2D = AStarGrid2D.new()
var valid_positions: Array[Vector2i]
var start_cell: Vector2i
var end_cell: Vector2i

var follow_points: Array[Vector2i]

@onready var follow_spline: Curve2D = Curve2D.new()

const speed: float = 60.0
var direction: Vector2 = Vector2.ZERO

var is_started: bool = false
@export var delay_before_active: float = 0.0

func start():
	is_started = true
	
func stop():
	is_started = false

var is_move_forced: bool = false
var forced_dir: Vector2 = Vector2.ZERO
func start_force_move_dir(dir: Vector2):
	is_move_forced = true
	forced_dir = dir
	follow_spline.clear_points()
	follow_points.clear()

func stop_force_move():
	is_move_forced = false
	forced_dir = Vector2.ZERO

func init_path_grid() -> void:
	AStar_grid.size 	 = walls_map.get_used_rect().size
	AStar_grid.cell_size = walls_map.tile_set.tile_size
	AStar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	AStar_grid.jumping_enabled = true
	AStar_grid.update()
	
	# Set which tile is wall and nothing
	for tile_x in range(AStar_grid.size.x):
		for tile_y in range(AStar_grid.size.y):
			var tile_pos: Vector2i = Vector2i(tile_x, tile_y)
			var is_wall: bool = walls_map.get_cell_source_id(0, tile_pos) == 1
			AStar_grid.set_point_solid(tile_pos, is_wall)
			if !is_wall:
				valid_positions.append(tile_pos)


func update_path(dest_point: Vector2i = Vector2i(-1, -1)) -> Array[Vector2i]:
	start_cell = path_map.local_to_map(position)
	end_cell   = path_map.local_to_map(player.position) if dest_point.x == -1 else dest_point
	
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
var initial_start_pos: Vector2 = Vector2(-1, -1)
var progress: float = 0.0
func follow_player():
	if found_player_state == FOUND_STATE.sees_nothing and follow_points.size() == 0: return
	
	var is_first = true
	if found_player_state == FOUND_STATE.just_saw:
		found_player_state = FOUND_STATE.follows
		
		follow_points = update_path()
		follow_spline.clear_points()
		
		for point in follow_points:
			if is_first:
				initial_start_pos = position
				follow_spline.add_point(position)
				is_first = false
			else:
				var pos = path_map.map_to_local(point)
				follow_spline.add_point(pos)
		
		progress = 0
	
	var first_segment_len: float = follow_spline.get_point_position(0).distance_to(follow_spline.get_point_position(1))

	progress += speed * get_physics_process_delta_time()

	if follow_spline.point_count > 1:
		position = follow_spline.sample_baked(progress, false)
	
	if progress >= first_segment_len:
		if found_player_state == FOUND_STATE.follows:
			follow_points = update_path()
		follow_spline.clear_points()
		
		for point in follow_points:
			if is_first:
				initial_start_pos = position
				follow_spline.add_point(position)
				is_first = false
			else:
				var pos = path_map.map_to_local(point)
				follow_spline.add_point(pos)
		
		progress = 0






var pick_timing: float = 1.0 # in seconds
var timing: float = 0.0
var search_rad: int = 20
var found_pos: Vector2 = Vector2(-1, 0)
func wander():
	follow_spline.clear_points()
	
	if follow_points.size() <= 1:
		valid_positions.shuffle()
		var cur_tile_pos: Vector2 = path_map.local_to_map(position)
#
		for valid_pos in valid_positions:
			if cur_tile_pos.distance_to(valid_pos) <= search_rad:
				found_pos = valid_pos
				break;
		
		follow_points = update_path(found_pos)
	
	for point in follow_points:
		var pos = path_map.map_to_local(point)
		follow_spline.add_point(pos)
	
	var first_segment_len: float = follow_spline.get_point_position(0).distance_to(follow_spline.get_point_position(1))

	progress += speed * get_physics_process_delta_time()

	if follow_spline.point_count > 1:
		position = follow_spline.sample_baked(progress, false)
	
	if progress >= first_segment_len:
		follow_points.remove_at(0)
		progress = 0
		timing = 0
#====================================================================================

var spl_pos: float = 0.0
var timer: float = 0.0
func _draw() -> void:
	if true: return
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
		
		draw_circle(follow_spline.samplef(spl_pos*follow_spline.point_count)-position, 2, Color.ORANGE)
		draw_circle(follow_spline.sample(0, spl_pos)-position, 2, Color.DARK_KHAKI)
		


func _ready():
	%enemy_anim.self_modulate = tint
	%enemy_anim.play("default")
	init_path_grid()



func _process(delta: float) -> void:
	queue_redraw()
	
	if !is_started: return
	
	if delay_before_active > 0:
		delay_before_active -= delta
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, player.position, 1)
	var result = space_state.intersect_ray(query)
	
	if result and result.collider is Player:
		if found_player_state == FOUND_STATE.sees_nothing:
			found_player_state = FOUND_STATE.just_saw
	else:
		if found_player_state == FOUND_STATE.follows:
			initial_start_pos = Vector2(-1, -1)
			found_player_state = FOUND_STATE.sees_nothing
	
	if !is_started: return
	if delay_before_active > 0: return
	
	
	if !is_move_forced:
		if found_player_state == FOUND_STATE.sees_nothing:
			wander()
		else:
			follow_player()
	else:
		position += forced_dir * speed * delta


func _physics_process(delta):
	pass
