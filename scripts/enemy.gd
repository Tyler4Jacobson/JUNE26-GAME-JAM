extends Node2D

@onready var tile_map = $"../TileMap"
@onready var sprite_2d = $Sprite2D

var astar_grid: AStarGrid2D

func _ready():
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(8, 8)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	var region_size = astar_grid.region.size
	var region_position = astar_grid.region.position
	
	for x in region_size.x:
		for y in region_size.y:
			var tile_position = Vector2i(
				x + region_position.x,
				y + region_position.y
			)
			
			var tile_data = tile_map.get_cell_tile_data(0, tile_position)
			
			if tile_data == null or tile_data.get_custom_data("Navigation Layer 0"):
				astar_grid.set_point_solid(tile_position) 

func _process(delta):
	if is_moving:
		return
	
	move()
	
func move():
	var path = astar_grid.get_id_path(
		tile_map.local_to_map(global_position),
		tile_map.local_to_map(player.global_position)
	)
	
	path.pop_front()
	
	if path.is_empty():
		print("can't find path")
		return
		
	var original_position = Vector2(global_position)
	
	global_position = tile_map.map_to_local(path[0])
	sprite_2d.global_position = original_position

func _physics_process(delta):
	if is_moving:
		sprite_2d.global_position = sprite2d.global_position.move_toward(global_position, 1)
		
		if sprite_2d.global_position != global_position:
			return
			
		is_moving = false  
