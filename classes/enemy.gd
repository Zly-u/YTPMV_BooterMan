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

var found_player: bool = false
var follow_points: Array[Vector2i]

@onready var follow_spline: Curve2D = Curve2D.new()

const speed: float = 110.0
var direction: Vector2 = Vector2.ZERO

var is_started: bool = false
@export var delay_before_active: float = 0.0

func start():
	is_started = true

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

var progress: float = 0.0
func follow_player():
	if !found_player and follow_points.size() == 0: return
	
	if found_player and follow_points.size() <= 1:
		progress = 0
		follow_points = update_path()
	
	follow_spline.clear_points()
	if follow_points.size() < 2: return
	
	for point in follow_points:
		var pos = path_map.map_to_local(point)
		follow_spline.add_point(pos)
	
	var first_segment_len: float = follow_spline.get_point_position(0).distance_to(follow_spline.get_point_position(1))

	if follow_spline.point_count > 1:
		position = follow_spline.sample_baked(progress, false)
	
	progress += speed * get_process_delta_time()
	
	if progress >= first_segment_len:
		follow_points.remove_at(0)
		progress = 0
		if found_player:
			follow_points = update_path()


var pick_timing: float = 1.0 # in seconds
var timing: float = 0.0
var search_rad: int = 10
var found_pos: Vector2 = Vector2(-1, 0)
func wander():
	if timing > 0:
		timing -= get_process_delta_time()
	else:
		valid_positions.shuffle()
		var cur_tile_pos: Vector2 = path_map.local_to_map(position)
		
		for valid_pos in valid_positions:
			if cur_tile_pos.distance_to(valid_pos) <= search_rad:
				found_pos = valid_pos
				break;
		
		timing = pick_timing
		progress = 0
	
	follow_spline.clear_points()
	
	if follow_points.size() <= 1:
		follow_points = update_path(found_pos)
	
	for point in follow_points:
		var pos = path_map.map_to_local(point)
		follow_spline.add_point(pos)
	
	var first_segment_len: float = follow_spline.get_point_position(0).distance_to(follow_spline.get_point_position(1))

	progress += speed * get_process_delta_time()

	if follow_spline.point_count > 1:
		position = follow_spline.sample_baked(progress, false)
	
	
	
	if progress >= first_segment_len:
		follow_points.remove_at(0)
		progress = 0
		timing = 0


var spl_pos: float = 0.0
var timer: float = 0.0
func _draw() -> void:
#	if true: return
#	timer += get_process_delta_time()
#	spl_pos = 0.5+sin(timer)*0.5
	
#	var line_points = []
#	for point in follow_spline.point_count:
#		line_points.append(follow_spline.get_point_position(point)-position)
		
#	draw_polyline(line_points, %enemy_anim.self_modulate, 2)
	
#	draw_line(Vector2.ZERO, player.position-position, Color.GREEN if found_player else Color.RED, 1)
	
	var bezier_points = []
	if follow_spline.point_count != 0:
		var bezier_samples: float = 100.0
		for sample in bezier_samples:
			bezier_points.append(follow_spline.samplef(follow_spline.point_count*(sample/bezier_samples))-position)
		draw_polyline(bezier_points, Color.RED, 3)
		
#		draw_circle(follow_spline.samplef(spl_pos*follow_spline.point_count)-position, 2, Color.ORANGE)
#		draw_circle(follow_spline.sample(0, spl_pos)-position, 2, Color.DARK_KHAKI)
		


func _ready():
	%enemy_anim.self_modulate = tint
	init_path_grid()



func _process(delta: float) -> void:
	queue_redraw()
	
	if !is_started: return
	
	if delay_before_active > 0:
		delay_before_active -= delta
	



func _physics_process(delta):
	if !is_started: return
	if delay_before_active > 0: return
	
	if found_player:
		follow_player()
	else:
		wander()
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(position, player.position, 1)
	var result = space_state.intersect_ray(query)
	
	
	if result and result.collider is Player:
		found_player = true
	else:
		found_player = false
