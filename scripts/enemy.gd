extends CharacterBody2D

@onready var tile_map = $".."
@onready var sprite_2d = $Sprite2D
@onready var player = $"../player"

var is_moving = false
var astar_grid: AStarGrid2D
const tile_size: Vector2 = Vector2(16,16)
var sprite_node_pos_tween: Tween
var timer = 0.0

# Called when the node enters the scene tree for the first time.
# Initialize AStarGrid, used for pathfinding, and fill in impassible tiles
func _ready() -> void:
	astar_grid = AStarGrid2D.new()
	astar_grid.region = tile_map.get_used_rect()
	astar_grid.cell_size = Vector2(32,32)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	var region_size = astar_grid.region.size			# Total size of tile_map
	var region_position = astar_grid.region.position 	# Origin position of the tile_map (upper left)
	
	# Scans through all the tiles in the tile_map
	for x in region_size.x:
		for y in region_size.y:
			var tile_position = Vector2i(
				x + region_position.x,
				y + region_position.y
			)
			
			# Check if tile is impassible
			var tile_data = tile_map.get_cell_tile_data(tile_position)
			if tile_data != null:
				astar_grid.set_point_solid(tile_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	#print(tile_map.get_children())
	var interval = 0.5
	# If the player moves, update the path
	# TODO: This feels really cheap and messy
	if is_moving:
		timer += delta
		if timer >= interval:
			is_moving = false
			timer -= interval
		return
	move()
	
# Move enemy one step toward player along AStar Path
func move() -> void:
	if player == null:
		printerr("ERROR: enemy has no player to target")
	
	var path = astar_grid.get_id_path(
		tile_map.local_to_map(global_position),
		tile_map.local_to_map(player.global_position)
	)
	
	# Stop movement if player is out of range
	# TODO: Maybe a smaller 'agro' range, but then a greater range that it will continue to follow for
	if path.size() > 10:
		is_moving = false
		return
	
	# Take next step along the path
	var original_position = path.pop_front()
	
	if path.is_empty():
		#print("can't find path")
		return
		
	var next_position = path[0]
	
	global_position = tile_map.map_to_local(next_position)
	sprite_2d.global_position = tile_map.map_to_local(original_position)
	
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property(sprite_2d, "global_position", global_position, 0.185)
	
	#print("original_position = ", original_position)
	#print("next_position = ", path[0])
	
	is_moving = true
