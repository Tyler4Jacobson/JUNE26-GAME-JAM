extends Node2D

@onready var ground_layer: TileMapLayer = $ground_layer
@onready var playground: TileMapLayer = $playground

var global_astar: AStarGrid2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var size_x = randi_range(10, 30)
	var size_y = randi_range(10, 30)
	
	initialize_grid(size_x, size_y)
	procedural.randomize_grid(ground_layer, randf_range(0.1, 0.2))
	procedural.fill_holes(ground_layer)
	
	# Create AStarGrid after walls have been set
	build_pathfinding_grid()
	
	#used for both player and enemies
	var safe_spots = get_valid_spawn_points()
	safe_spots.shuffle() 
	var atlas_coords = Vector2i(0, 0)
	
	#place player
	if !safe_spots.is_empty():
		var player_location = safe_spots.pop_back()
		playground.set_cell(player_location, 1, atlas_coords, 1)
	
	#place enemies
	var enemy_count = 10
	for x in range(enemy_count):
		if not safe_spots.is_empty(): 
			var location = safe_spots.pop_back()
			playground.set_cell(location, 2, atlas_coords, 2)
	
	await get_tree().process_frame
	assign_data_to_spawned_scenes()
	
	#place collectibles
	var coin_count = game_manager.get_coin_count()
	for x in range(coin_count):
		if not safe_spots.is_empty():
			var location = safe_spots.pop_back()
			playground.set_cell(location, 3, atlas_coords, 3)

# Setup of AStarGrid
func build_pathfinding_grid() -> void:
	global_astar = AStarGrid2D.new()
	global_astar.region = ground_layer.get_used_rect()
	global_astar.cell_size = Vector2(32, 32)
	global_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	global_astar.update()
	
	var used_cells = ground_layer.get_used_cells()
	for cell_pos in used_cells:
		var tile_data = ground_layer.get_cell_tile_data(cell_pos)
		if tile_data != null and tile_data.get_custom_data("is_wall") == true:
			global_astar.set_point_solid(cell_pos)

func assign_data_to_spawned_scenes() -> void:
	var spawned_player = playground.get_node_or_null("player") 
	
	for child in playground.get_children():
		if child.name.begins_with("Enemy") or child.has_method("move"):
			child.astar_grid = global_astar
			child.player = spawned_player
			child.tile_map = ground_layer

func get_valid_spawn_points() -> Array[Vector2i]:
	var valid_tiles: Array[Vector2i] = []
	var used_cells = ground_layer.get_used_cells()
	
	for cell_pos in used_cells:
		var tile_data = ground_layer.get_cell_tile_data(cell_pos)
		if tile_data != null and tile_data.get_custom_data("is_wall") == false:
			valid_tiles.append(cell_pos)
			
	return valid_tiles

func initialize_grid(size_x: int, size_y: int):
	for x in range(size_x*-1, size_x):
		for y in range(size_y*-1, size_y):
			var tile_pos = Vector2i(x, y)
			var atlas_pos = Vector2i(6, 11) #all blank, edges later
			ground_layer.set_cell(tile_pos, 0, atlas_pos)
	set_grid_boundary(size_x, size_y)
	
func set_grid_boundary(size_x: int, size_y: int):
	for x in range(size_x*-1, size_x):
		# set bottom layer
		var tile_pos = Vector2i(x, size_y-1)
		var atlas_pos = Vector2i(5, 9)
		if x == size_x*-1:
			atlas_pos = Vector2i(4, 9)
		elif x == size_x-1:
			atlas_pos = Vector2i(6, 9)
			
		ground_layer.set_cell(tile_pos, 0, atlas_pos)
		
		# set top layer
		tile_pos = Vector2i(x, size_y*-1)
		atlas_pos = Vector2i(5, 8)
		if x == size_x*-1:
			atlas_pos = Vector2i(4, 8)
		elif x == size_x-1:
			atlas_pos = Vector2i(6, 8)
			
		ground_layer.set_cell(tile_pos, 0, atlas_pos)
	
	# don't double do corners
	for y in range(size_y*-1 + 1, size_y-1):
		# set left layer
		var tile_pos = Vector2i(size_x*-1, y)
		var atlas_pos = Vector2i(2, 9)
		#if y == size_y-1:
			#atlas_pos = Vector2i(2, 9)
		ground_layer.set_cell(tile_pos, 0, atlas_pos)
		
		# set right layer
		tile_pos.x = tile_pos.x * -1 - 1
		atlas_pos = Vector2i(0, 9)
		ground_layer.set_cell(tile_pos, 0, atlas_pos)
