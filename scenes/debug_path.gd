extends TileMap

@onready var enemy: Enemy = %Enemy
@onready var player: Player = %Player
@onready var walls_map: TileMap = %walls

@onready var AStar_grid: AStarGrid2D = AStarGrid2D.new()
var start_cell: Vector2i
var end_cell: Vector2i

func init_grid() -> void:
	AStar_grid.size 	 = walls_map.get_used_rect().size
	AStar_grid.cell_size = walls_map.tile_set.tile_size
	AStar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	AStar_grid.jumping_enabled = true
	AStar_grid.update()

	# Set which tile is wall and nothing
	for tile_x in range(AStar_grid.size.x):
		for tile_y in range(AStar_grid.size.y):
			var tile_pos = Vector2i(tile_x, tile_y)
			AStar_grid.set_point_solid(tile_pos, walls_map.get_cell_source_id(0, tile_pos) == 1)


func update_path() -> Array[Vector2i]:
	clear()
	for lbl in %DEBUG_Labels.get_children():
		lbl.queue_free()
		
	start_cell = local_to_map(enemy.position)
	end_cell   = local_to_map(player.position)
	
	if start_cell == end_cell or !AStar_grid.is_in_boundsv(start_cell) or !AStar_grid.is_in_boundsv(end_cell):
		return []
	
	var path_ids = AStar_grid.get_id_path(start_cell, end_cell)
	
	var num = 0
	for id in path_ids:
		set_cell(0, id, 0, Vector2(0, 0))
		
		var label = Label.new()
		%DEBUG_Labels.add_child(label)
		label.text = str(num)
		label.position = map_to_local(id)
		num += 1
	
	return path_ids


func _ready() -> void:
	return
	init_grid()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return
	update_path()
